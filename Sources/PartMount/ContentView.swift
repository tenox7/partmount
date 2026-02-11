import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var appState: AppState
    @StateObject private var partManager = PartitionManager()
    @State private var selectedId: Int?
    @State private var showFilePicker = false
    @State private var dropHighlight = false
    @State private var readOnly = false

    var selectedPartition: PartitionInfo? {
        partManager.partitions.first { $0.id == selectedId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            dropZone
            partitionList
            Text(appState.status)
                .font(.caption)
                .foregroundColor(.secondary)
            buttonBar
        }
        .padding(20)
        .frame(width: 420, height: 440)
        .onChange(of: appState.imageURL) { url in
            selectedId = nil
            guard let url else {
                partManager.partitions = []
                appState.status = "Ready"
                return
            }
            appState.status = "Loading partitions\u{2026}"
            partManager.load(url: url) { msg in
                appState.status = msg
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.diskImage, .data],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                appState.imageURL = url
            }
        }
    }

    private var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundColor(dropHighlight ? .accentColor : .secondary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(dropHighlight ? Color.accentColor.opacity(0.1) : Color.clear)
                )
            if let url = appState.imageURL {
                VStack(spacing: 4) {
                    Image(systemName: "doc.fill").font(.title)
                    Text(url.lastPathComponent).font(.headline)
                    Text(url.deletingLastPathComponent().path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.down.doc").font(.title)
                    Text("Drop disk image here or click to select")
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 90)
        .contentShape(Rectangle())
        .onTapGesture { showFilePicker = true }
        .onDrop(of: [.fileURL], isTargeted: $dropHighlight) { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                guard let url else { return }
                DispatchQueue.main.async { appState.imageURL = url }
            }
            return true
        }
    }

    private var partitionList: some View {
        List(partManager.partitions, selection: $selectedId) { part in
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(part.number.map { "#\($0)" } ?? "\(part.id)")
                        .frame(width: 28, alignment: .trailing)
                        .font(.body.monospacedDigit())
                    Text(part.displayType)
                        .lineLimit(1)
                    Spacer()
                    Text(part.formattedSize)
                        .foregroundColor(.secondary)
                        .font(.body.monospacedDigit())
                    if partManager.mounted[part.id] != nil {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                            .font(.caption2)
                    }
                }
                if !part.subtitle.isEmpty {
                    Text(part.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 32)
                }
            }
            .opacity(part.synthesized ? 0.5 : 1.0)
            .tag(part.id)
        }
    }

    private var isMounted: Bool {
        selectedPartition.map { partManager.mounted[$0.id] != nil } ?? false
    }

    private var buttonBar: some View {
        HStack {
            Toggle("Read only", isOn: $readOnly)
                .toggleStyle(.checkbox)
            Spacer()
            Button(isMounted ? "Unmount" : "Mount") {
                guard let part = selectedPartition else { return }
                if isMounted {
                    guard let info = partManager.mounted[part.id] else { return }
                    let partId = part.id
                    let isLast = partManager.mounted.count == 1
                    appState.busy = true
                    appState.status = "Unmounting\u{2026}"
                    DispatchQueue.global(qos: .userInitiated).async {
                        let (status, ok) = partManager.performUnmount(info: info, isLast: isLast)
                        DispatchQueue.main.async {
                            if ok { partManager.mounted.removeValue(forKey: partId) }
                            appState.status = status
                            appState.busy = false
                        }
                    }
                } else {
                    guard let url = appState.imageURL else { return }
                    appState.busy = true
                    appState.status = "Mounting\u{2026}"
                    DispatchQueue.global(qos: .userInitiated).async {
                        let (status, info) = partManager.performMount(partition: part, imageURL: url, readOnly: readOnly)
                        DispatchQueue.main.async {
                            if let info { partManager.mounted[part.id] = info }
                            appState.status = status
                            appState.busy = false
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedPartition == nil || appState.busy)
        }
    }
}
