#!/usr/bin/env ruby

require 'bundler'
Bundler.setup :default
require 'vkontakte'

class Hash
        def fizteh?
                return ((['297', '55111'].include? self['university']) and ([0, 2012, 2013, 2014, 2015, 2016, 2017].include? self['graduation'].to_i))
        end
end

faculties = {
        '27176' => 'FIVT', 8 => 'FIVT',
        '1300' => 'FMBF', 3 => 'FMBF',
        '26881' => 'FRTK', 0 => 'FRTK',
        '11585' => 'FOPF', '170169' => 'FOPF', '95959' => 'FOPF', 1 => 'FOPF',
        '2080' => 'FUPM', 6 => 'FUPM',
        '49264' => 'FFKE', '100641' => 'FFKE', 4 => 'FFKE',
        '32158' => 'FAKI', 2 => 'FAKI',
        '112770' => 'FPFE', '1303' => 'FPFE', 7 => 'FPFE',
        '56925' => 'NBIK', 9 => 'NBIK',
        '1298' => 'FALT', 5 => 'FALT'
}

# ---- LOGIN ON VK.COM, CHECKING DATA ----

#CLIENT_SECRET = 'd2L7k1xbFWHCRetVjMcy'
#CLIENT_ID     = '2900265'
#CLIENT_SECRET = 'A8hIBpnuwVDRrvfqiWI2'
#CLIENT_ID     = '2876645'
#CLIENT_ID     = '2876644'
#CLIENT_SECRET = 'ew1N8r3iPHnUQx3YamAP'
#CLIENT_ID     = '2903616'
#CLIENT_SECRET = '9IiI7q34BSQqFmvljVPM'
CLIENT_ID     = '2905512'
CLIENT_SECRET = '1bHMP2LtvlJUfYsieQ3w'


#puts email = 'nekit_one@mail.ru'
#puts email = 'andrew_skaut@inbox.ru'
#puts email = 'aidar@biktimirov.net'
#puts email = '79162510865'
puts email = 'ideal1189@gmail.com'
# Hide password
print 'Password: '
system "stty -echo"
pass = $stdin.gets.chomp
system "stty echo"

vk = Vkontakte::Client.new(CLIENT_ID, CLIENT_SECRET)
vk.login!(email, pass)
puts

info = vk.api.getUserInfoEx
self_id, self_name, self_fac = info['user_id'], info['user_name'].gsub(' ', '_'), nil
friend_id = vk.api.friends_get(:fields => 'education', :uid => self_id)[0]['uid']
vk.api.friends_get(:fields => 'education', :uid => friend_id.to_s).each do |friend|
        self_fac = faculties[friend['faculty']] if friend['uid'].to_s == self_id
end

if !self_fac
        puts "Sorry, but it seems that you are not a MIPT student (according to the data given on your vk.com page)"
        exit 1
end

# ---- END OF LOGIN AND CHECKING ----


# ---- GET THE DATA FROM PREVIOUS RUNNINGS ----

system('mkdir -p graph')
system('mkdir -p results')

graph = {}
facs = {}
friendship = {}
facs.default = 0
friendship.default = 0

Dir::entries('./graph').each do |filename|
        if !['.', '..'].include? filename
                vertex = filename.split('-')
                File.open('./graph/' + filename).readlines.each do |t|
                        f = t.chomp.split('-')
                        if !graph[[vertex[0], f[0]]]
                                friendship[[vertex[1], f[1]]] += 1
                                graph[[vertex[0], f[0]]] = true
                        end
                        if !graph[[f[0], vertex[0]]]
                                friendship[[f[1], vertex[1]]] += 1
                                graph[[f[0], vertex[0]]] = true
                        end
                        if !graph[[f[0], f[0]]]
                                facs[f[1]] += 1
                                graph[[f[0], f[0]]] = true
                        end
                end
                if !graph[[vertex[0], vertex[0]]]
                        facs[vertex[1]] += 1
                        graph[[vertex[0], vertex[0]]] = true
                end
        end
end

# ---- END OF RESTORING DATA ----


# ---- BIGBFS ----

queue = [self_id]
visited = {self_id => true}
fc = [self_fac]
nam = [self_name]
done, add = 0, 0

while queue.any?
        list = []
        vk.api.friends_get(:fields => 'education', :uid => queue[0]).each do |friend|
                id, fac, name = friend['uid'], faculties[friend['faculty']], friend['first_name'] + '_' + friend['last_name']
                if friend.fizteh? and fac
                        if !visited[id]
                                queue << id
                                visited[id] = true
                                fc << fac
                                nam << name
                        end
                        if !graph[[id.to_s, id.to_s]]
                                facs[fac] += 1
                                graph[[id.to_s, id.to_s]] = true
                        end
                        if !graph[[queue[0].to_s, id.to_s]]
                                friendship[[fc[0], fac]] += 1
                                graph[[queue[0].to_s, id.to_s]] = true
                        end
                        if !graph[[id.to_s, queue[0].to_s]]
                                friendship[[fac, fc[0]]] += 1
                                graph[[id.to_s, queue[0].to_s]] = true
                        end
                        list << id.to_s + '-' + fac + '-' + name
                end
        end
        if !graph[[queue[0].to_s, queue[0].to_s]]
                facs[fc[0]] += 1
                graph[[queue[0].to_s, queue[0].to_s]] = true
        end
        done += 1
        puts nam[0] + ' ' + (queue.size - 1).to_s + ' ' + done.to_s

        fname = './graph/' + queue[0].to_s + '-' + fc[0].to_s + '-' + nam[0].to_s
        system("touch #{fname}")
        f = File.open(fname, 'r')
        s = ""
        old = 0
        while (s = f.gets) do
                list << s.chomp if s
                old += 1
        end
        list.uniq!
        add += list.size - old
        f.close
        f = File.open(fname + 'c', 'w')
        list.each{ |s| f.puts s }
        f.close
        File.unlink(fname)
        system("mv #{fname + 'c'} #{fname}")
        queue.shift
        fc.shift
        nam.shift
end

# ---- END OF BIGBFS ----

puts "Added #{add} edges"

f = File.open('results/facs', 'w')
(0..9).each do |i|
        f.puts faculties[i] + ' ' + facs[faculties[i]].to_s
end

# ---- PRINT THE FRIENDSHIP TABLE ----

f = File.open('results/friendship', 'w')
f.print '     '
(0..9).each do |i|
        f.print faculties[i].to_s + ' '
end
f.puts
(0..9).each do |i|
        f.print faculties[i].to_s + ' '
        (0..9).each do |j|
                t = friendship[[faculties[i], faculties[j]]]
                t /= 2 if i == j
                if i != j
                        e = facs[faculties[i]] * facs[faculties[j]]
                        t = (t * 10000) / e if e > 0
                else
                        e = (facs[faculties[i]] * (facs[faculties[i]] - 1)) / 2
                        t = (t * 10000) / e if e > 0
                end
                f.print t.to_s + ' ' * (5 - t.to_s.length)
        end
        f.puts
end
f.close

# ---- END OF FRIENDSHIP TABLE ----
