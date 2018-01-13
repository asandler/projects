a = File.readlines(ARGV[0]).map{|s| s.chomp.split(/[ :;<>?!@#$&-_".,=-]/)}.flatten.map{|s| s.empty? ? nil : s}.compact

v_in = {}
v_out = {}
weights = Hash.new(0)

(0..a.size - 2).each do |i|
    v_in[a[i + 1]] ||= []
    v_in[a[i + 1]] << a[i]
    v_out[a[i]] ||= []
    v_out[a[i]] << a[i + 1]
    weights[[a[i], a[i + 1]]] += 1
end
v_in.each{|ar| ar.uniq!}
v_out.each{|ar| ar.uniq!}
#weights.each{|k, v| puts v.to_s + "   " + k.to_s if v > 1}

s = Hash.new(1)
d = 0.85
v_in[a[0]] = []

STDERR.puts "a.size = #{a.size}"

5.times do |t|
    run = 0
    a.each do |i|
        sum = 0
        v_in[i].each do |j|
            w_sum = 0
            v_out[j].each{|k| w_sum += weights[[j, k]]}
            sum += s[j] * weights[[j, i]] / w_sum if w_sum > 0
        end
        s[i] = (1 - d) + d * sum
        run += 1
        STDERR.puts run if run % 1000 == 0
    end
    STDERR.puts t
end

s.each{|k, v| puts v.to_s + "\t" + k.to_s}
