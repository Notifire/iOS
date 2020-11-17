#!/usr/bin/ruby

file_content = <<-SECRETS_FILE_STRING
//
//  Config.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

// MARK: - Secrets
extension Config {
    static let sentryDsn = "#{ENV['SENTRY_DSN']}"
}
SECRETS_FILE_STRING

file = File.new("#{ENV['SRCROOT']}/Notifire/Config/Config+Secrets.swift", "w")
file.puts(file_content)
file.close