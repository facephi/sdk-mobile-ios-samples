//
//  FlowSelector.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/FlowSelector.kt (DemoIDV).
//

import sdk
import SwiftUI

struct FlowSelector: View {
    let flows: [IntegrationFlowData]
    let selected: IntegrationFlowData?
    let onSelected: (IntegrationFlowData) -> Void

    @State private var expanded = false

    var body: some View {
        VStack(spacing: 4) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                HStack {
                    Text(selected?.name ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(.demoOnSurface)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.demoOnSurfaceVariant)
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(expanded ? Color.sdkPrimary : Color.demoOutline, lineWidth: expanded ? 2 : 1)
                )
                .overlay(alignment: .topLeading) {
                    Text("Select flow")
                        .font(.system(size: 12))
                        .foregroundColor(expanded ? .sdkPrimary : .demoOnSurfaceVariant)
                        .padding(.horizontal, 4)
                        .background(Color.sdkBackground)
                        .offset(x: 12, y: -8)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(flows, id: \.id) { flow in
                        Button {
                            expanded = false
                            onSelected(flow)
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer().frame(height: 4)
                                Text(flow.name)
                                    .font(.system(size: 16))
                                    .foregroundColor(.demoOnSurface)
                                Text("Type: \(flow.operationType)")
                                    .font(.demoBodySmall)
                                    .foregroundColor(.demoOnSurfaceVariant)
                                Text("ID: \(flow.id)")
                                    .font(.demoBodySmall)
                                    .foregroundColor(.demoOnSurfaceVariant)
                                Spacer().frame(height: 4)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.sdkBackground)
                        .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
