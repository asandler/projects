class Map
  def initialize ar
    @pool = ar.map{|s| s.chars}
    find_me
    build_admissible_set
  end

  def find_me
    @pool.each_with_index do |row, i|
      row.each_with_index do |c, j|
        @me_x, @me_y = i, j if c == 'm' or c == 'M'
      end
    end
  end

  def build_admissible_set
    @admissible_set = []
    @pool.each_with_index do |row, i|
      row.each_with_index do |c, j|
        next if c == '@'
        if c == 'x' or c == 'X' or c == '#'
          @admissible_set << [i, j]
          next
        end

        neigh = [@pool[i][j-1], @pool[i][j+1], @pool[i-1][j], @pool[i+1][j]]
        if neigh.select{|n| n == '@'}.size >= 2
          next
        end

        if neigh.select{|n| n == '@'}.size == 1
          flag = false
          if @pool[i][j-1] == '@' or @pool[i][j+1] == '@'
            tmp = i
            while @pool[tmp-1][j] != '@'
              flag |= (['x', 'X'].include? @pool[tmp][j])
              tmp -= 1
            end
            tmp = i
            while @pool[tmp+1][j] != '@'
              flag |= (['x', 'X'].include? @pool[tmp][j])
              tmp += 1
            end
          else
            tmp = j
            while @pool[i][tmp-1] != '@'
              flag |= (['x', 'X'].include? @pool[i][tmp])
              tmp -= 1
            end
            tmp = j
            while @pool[i][tmp+1] != '@'
              flag |= (['x', 'X'].include? @pool[i][tmp])
              tmp += 1
            end
          end

          @admissible_set << [i, j] if flag
        else
          @admissible_set << [i, j]
        end
      end
    end
  end

  def neighbours
    answer = []
    [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |x, y|

      if @pool[@me_x + x][@me_y + y] == '.'
        answer << Marshal.load(Marshal.dump(self))
        if @pool[@me_x][@me_y] == 'm'
          answer[-1].set @me_x, @me_y, '.'
          answer[-1].set @me_x + x, @me_y + y, 'm'
        else
          answer[-1].set @me_x, @me_y, 'x'
          answer[-1].set @me_x + x, @me_y + y, 'm'
        end
      end

      if @pool[@me_x + x][@me_y + y] == 'x'
        answer << Marshal.load(Marshal.dump(self))
        if @pool[@me_x][@me_y] == 'm'
          answer[-1].set @me_x, @me_y, '.'
          answer[-1].set @me_x + x, @me_y + y, 'M'
        else
          answer[-1].set @me_x, @me_y, 'x'
          answer[-1].set @me_x + x, @me_y + y, 'M'
        end
      end

      if @pool[@me_x + x][@me_y + y] == '#' and (@pool[@me_x + x * 2][@me_y + y * 2] == 'x' or @pool[@me_x + x * 2][@me_y + y * 2] == '.')
        answer << Marshal.load(Marshal.dump(self))
        if @pool[@me_x][@me_y] == 'm'
          answer[-1].set @me_x, @me_y, '.'
        else
          answer[-1].set @me_x, @me_y, 'x'
        end

        answer[-1].set @me_x + x, @me_y + y, 'm'

        if @pool[@me_x + x * 2][@me_y + y * 2] == 'x'
          answer[-1].set @me_x + x * 2, @me_y + y * 2, 'X'
        else
          answer[-1].set @me_x + x * 2, @me_y + y * 2, '#'
        end
      end

      if @pool[@me_x + x][@me_y + y] == 'X' and (@pool[@me_x + x * 2][@me_y + y * 2] == 'x' or @pool[@me_x + x * 2][@me_y + y * 2] == '.')
        answer << Marshal.load(Marshal.dump(self))
        if @pool[@me_x][@me_y] == 'm'
          answer[-1].set @me_x, @me_y, '.'
        else
          answer[-1].set @me_x, @me_y, 'x'
        end

        answer[-1].set @me_x + x, @me_y + y, 'M'

        if @pool[@me_x + x * 2][@me_y + y * 2] == 'x'
          answer[-1].set @me_x + x * 2, @me_y + y * 2, 'X'
        else
          answer[-1].set @me_x + x * 2, @me_y + y * 2, '#'
        end
      end
    end

    answer.each{|a| a.find_me }
    return answer
  end

  def hash
    return @pool.map{|ar| ar.join}.join.hash
  end

  def set x, y, symb
    @pool[x][y] = symb
  end
  
  def final?
    @pool.each_with_index do |row, i|
      row.each_with_index do |c, j|
        return false if c == '#'
      end
    end
    return true
  end

  def pretty_print
    @pool.each{|ar| puts ar.join}
    puts
  end

  def admissible_print
    @pool.each_with_index do |row, i|
      row.each_with_index do |c, j|
        if @admissible_set.include? [i, j]
          print 1
        else
          print 0
        end
      end
      puts
    end
    puts
  end
end

def solve_sokoban start
  visited = {}
  queue = [start]
  pred = {}
  while queue.size > 0
    top = queue.shift
    visited[top.hash] = true
    if top.final?
      path = []
      while top.hash != start.hash
        path.unshift top
        top = pred[top]
      end
      path.unshift start
      path.each{|pos| pos.pretty_print}

      return "Solved"
    end
    top.neighbours.each do |n|
      if not visited[n.hash]
        pred[n] = top
        visited[n.hash] = true
        queue << n
      end
    end
  end
  return "No solution"
end

Map.new(File.readlines(ARGV[0]).map{|s| s.chomp}).admissible_print
puts solve_sokoban(Map.new(File.readlines(ARGV[0]).map{|s| s.chomp}))
