////
////  Memories_Test.swift
////  RMBR
////
////  Created by Sam Prausnitz-Weinbaum on 4/5/20.
////  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
////
//
//import SwiftUI
//
//struct Memories_Test: View {
//    @State private var memories: [Memories] = []
//    
//    fileprivate func memoryListElement(_ memory: Memory) -> some View {
//        return //                         When the memory is clicked, grab its info
//            Button (action: {
//                self.title = memory.title
//                self.text = memory.text
//                //                            empty image arry
//                self.images.removeAll()
//                //                            add in all images for this memory
//                for uiim in memory.attachments {
//                    self.images.append(uiim)
//                }
//                self.showingMemory = memory
//                self.sheetType = "show"
//                self.showSheet = true
//            }) {
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(memory.title)
//                            .bold()
//                            .font(.headline)
//                        Text(beautifyDate(memory.date))
//                            .font(.caption)
//                        Text(memory.text)
//                    }
//                    .frame(height: 70)
//                    Spacer()
//                    Text(attachmentsText(memory.attachments.count))
//                }
//        }
//    }
//    
//    var body: some View {
//        List {
//            ForEach(memories) { memory in
//                self.memoryListElement(memory)
//            }
//        }
//    }
//}
//
//struct Memories_Test_Previews: PreviewProvider {
//    static var previews: some View {
//        Memories_Test()
//    }
//}
