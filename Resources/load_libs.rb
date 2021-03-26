require 'set'

APPDIR = ENV["APPDIR"]

apps = Dir["/#{APPDIR}/usr/bin/*"]

final_lib_list = Set.new

for app in apps
    output = `ldd #{app} 2> /dev/null`
    if $?.exitstatus != 0
        next
    end
    rx = /\s*.+?\s*\=\>\s*(.+?)\s*\(0x/
    for line in output.split "\n"
        match = rx.match(line)
        if match.nil?
            next
        end
        final_lib_list << match[1]
    end
end

system "mkdir -p '/#{APPDIR}/usr/lib'"

for el in final_lib_list
    if File.basename(el).start_with?('libstdc++.so') || File.basename(el).start_with?('libc.so') || File.basename(el).start_with?('libpthread.so') || File.basename('librt.so')
        STDERR.puts "Skipping #{el}..."
        next
    end
    system "cp '#{el}' '/#{APPDIR}/usr/lib'"
end