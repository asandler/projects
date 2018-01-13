x = []
y = []

while s = gets
    x << s.split.map{|x| x.to_f}[0]
    y << s.split.map{|x| x.to_f}[1]
end

x_mean = x.inject(:+).to_f / x.size
y_mean = y.inject(:+).to_f / y.size

sum = 0.0
sum_x2 = 0.0
sum_y2 = 0.0

(0..x.size - 1).each do |i|
    sum += (x[i] - x_mean) * (y[i] - y_mean)
    sum_x2 += (x[i] - x_mean) ** 2
    sum_y2 += (y[i] - y_mean) ** 2
end

puts sum / Math::sqrt(sum_x2 * sum_y2)
puts (sum / Math::sqrt(sum_x2 * sum_y2)) ** 2
