//
//  IAVCommandRunner.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IAVCommandRunner {
    func runRxCommand(command: AVCommand) -> Observable<AVCommandResponse>
    func runBatchRxCommands(commands: [AVCommand], app: AVApp) -> Observable<[AVCommandResponse]>
}
