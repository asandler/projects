require 'set'

State = Struct.new(:boxes, :player, :key)

Solution = Struct.new(:solved, :states, :expanded, :visited) do
  def solved?
    solved
  end

  def pushes
    return nil unless solved?

    states.length - 1
  end
end

class Board
  WALL = '@'
  FLOOR = '.'
  GOAL = 'x'
  BOX = '#'
  BOX_ON_GOAL = 'X'
  PLAYER = 'm'
  PLAYER_ON_GOAL = 'M'

  DIRECTIONS = [
    [0, -1],
    [0, 1],
    [-1, 0],
    [1, 0]
  ].freeze

  attr_reader :height, :width, :goals, :dead_squares, :initial_state

  def self.from_file(path)
    new(File.readlines(path, chomp: true))
  end

  def initialize(lines)
    lines = lines.map(&:chomp)
    raise ArgumentError, 'level is empty' if lines.empty?

    @height = lines.length
    @width = lines.map(&:length).max || 0
    @walkable = Set.new
    @goals = Set.new
    boxes = []
    player = nil
    player_count = 0

    lines.each_with_index do |line, row|
      line.chars.each_with_index do |cell, col|
        pos = encode(row, col)

        case cell
        when WALL
          next
        when FLOOR
          @walkable.add(pos)
        when GOAL
          @walkable.add(pos)
          @goals.add(pos)
        when BOX
          @walkable.add(pos)
          boxes << pos
        when BOX_ON_GOAL
          @walkable.add(pos)
          @goals.add(pos)
          boxes << pos
        when PLAYER
          @walkable.add(pos)
          player = pos
          player_count += 1
        when PLAYER_ON_GOAL
          @walkable.add(pos)
          @goals.add(pos)
          player = pos
          player_count += 1
        else
          raise ArgumentError, "unknown cell #{cell.inspect} at row #{row + 1}, column #{col + 1}"
        end
      end
    end

    raise ArgumentError, 'level must contain exactly one player' unless player_count == 1

    @initial_state = State.new(boxes.sort.freeze, player, nil)
    @dead_squares = build_dead_squares.freeze
  end

  def solve(max_states: nil)
    start_key = state_key(@initial_state.boxes, @initial_state.player)
    start = State.new(@initial_state.boxes, @initial_state.player, start_key)
    queue = [start]
    head = 0
    parents = { start_key => nil }
    states = { start_key => start }
    visited = Set[start_key]
    expanded = 0

    while head < queue.length
      state = queue[head]
      head += 1
      expanded += 1

      return solved_solution(state.key, parents, states, expanded, visited.size) if solved_boxes?(state.boxes)
      return Solution.new(false, [], expanded, visited.size) if max_states && expanded >= max_states

      enqueue_pushes(state, queue, parents, states, visited)
    end

    Solution.new(false, [], expanded, visited.size)
  end

  def solved_boxes?(boxes)
    boxes.all? { |box| @goals.include?(box) }
  end

  def render(state = @initial_state)
    boxes = state.boxes.to_set

    (0...@height).map do |row|
      (0...@width).map do |col|
        pos = encode(row, col)

        if boxes.include?(pos)
          goal?(pos) ? BOX_ON_GOAL : BOX
        elsif pos == state.player
          goal?(pos) ? PLAYER_ON_GOAL : PLAYER
        elsif goal?(pos)
          GOAL
        elsif walkable?(pos)
          FLOOR
        else
          WALL
        end
      end.join
    end.join("\n")
  end

  def pretty_print(state = @initial_state)
    puts render(state)
    puts
  end

  def admissible_print
    puts admissible_mask
    puts
  end

  def dead_square_print
    puts dead_square_mask
    puts
  end

  private

  def enqueue_pushes(state, queue, parents, states, visited)
    boxes = state.boxes
    boxes_set = boxes.to_set
    reachable = reachable_positions(boxes_set, state.player)

    boxes.each do |box|
      DIRECTIONS.each do |drow, dcol|
        stand = adjacent(box, -drow, -dcol)
        destination = adjacent(box, drow, dcol)

        next unless stand && destination
        next unless reachable.include?(stand)
        next unless free_for_box?(destination, boxes_set)
        next if @dead_squares.include?(destination)

        new_boxes = boxes.map { |pos| pos == box ? destination : pos }.sort.freeze
        key = state_key(new_boxes, box)
        next if visited.include?(key)

        new_state = State.new(new_boxes, box, key)
        visited.add(key)
        parents[key] = state.key
        states[key] = new_state
        queue << new_state
      end
    end
  end

  def solved_solution(goal_key, parents, states, expanded, visited)
    path = []
    key = goal_key

    while key
      path.unshift(states.fetch(key))
      key = parents.fetch(key)
    end

    Solution.new(true, path, expanded, visited)
  end

  def reachable_positions(boxes, start)
    visited = Set[start]
    queue = [start]
    head = 0

    while head < queue.length
      pos = queue[head]
      head += 1

      DIRECTIONS.each do |drow, dcol|
        next_pos = adjacent(pos, drow, dcol)
        next unless next_pos
        next if visited.include?(next_pos)
        next unless free_for_player?(next_pos, boxes)

        visited.add(next_pos)
        queue << next_pos
      end
    end

    visited
  end

  def state_key(boxes, player)
    canonical_player = reachable_positions(boxes.to_set, player).min

    "#{boxes.join(',')}|#{canonical_player}"
  end

  def build_dead_squares
    reachable = box_goal_reachable_positions
    dead = Set.new

    @walkable.each do |pos|
      next if reachable.include?(pos)

      dead.add(pos)
    end

    dead
  end

  def box_goal_reachable_positions
    reachable = @goals.dup
    queue = @goals.to_a
    head = 0

    while head < queue.length
      pos = queue[head]
      head += 1

      DIRECTIONS.each do |drow, dcol|
        previous_box = adjacent(pos, -drow, -dcol)
        player_stand = previous_box && adjacent(previous_box, -drow, -dcol)

        next unless previous_box && player_stand
        next unless walkable?(previous_box) && walkable?(player_stand)
        next if reachable.include?(previous_box)

        reachable.add(previous_box)
        queue << previous_box
      end
    end

    reachable
  end

  def admissible_mask
    mask { |pos| walkable?(pos) && !@dead_squares.include?(pos) }
  end

  def dead_square_mask
    mask { |pos| @dead_squares.include?(pos) }
  end

  def mask
    (0...@height).map do |row|
      (0...@width).map do |col|
        yield(encode(row, col)) ? '1' : '0'
      end.join
    end.join("\n")
  end

  def adjacent(pos, drow, dcol)
    row = pos / @width
    col = pos % @width
    next_row = row + drow
    next_col = col + dcol

    return nil if next_row.negative? || next_row >= @height
    return nil if next_col.negative? || next_col >= @width

    encode(next_row, next_col)
  end

  def encode(row, col)
    row * @width + col
  end

  def goal?(pos)
    @goals.include?(pos)
  end

  def walkable?(pos)
    @walkable.include?(pos)
  end

  def free_for_player?(pos, boxes)
    walkable?(pos) && !boxes.include?(pos)
  end

  def free_for_box?(pos, boxes)
    walkable?(pos) && !boxes.include?(pos)
  end
end

Map = Board

def solve_sokoban(start)
  solution = start.solve
  solution.states.each { |state| start.pretty_print(state) } if solution.solved?

  solution.solved? ? 'Solved' : 'No solution'
end

def usage
  'Usage: ruby solve.rb LEVEL [--quiet] [--debug]'
end

def run_cli(argv)
  debug = false
  quiet = false
  paths = []

  argv.each do |arg|
    case arg
    when '--debug'
      debug = true
    when '--quiet'
      quiet = true
    when '-h', '--help'
      puts usage
      return 0
    else
      paths << arg
    end
  end

  unless paths.length == 1
    warn usage
    return 1
  end

  board = Board.from_file(paths.first)
  if debug
    puts 'Dead-square mask:'
    board.dead_square_print
  end

  solution = board.solve
  if solution.solved?
    solution.states.each { |state| board.pretty_print(state) } unless quiet
    puts "Solved in #{solution.pushes} pushes (expanded #{solution.expanded}, visited #{solution.visited})"
    0
  else
    puts "No solution (expanded #{solution.expanded}, visited #{solution.visited})"
    2
  end
rescue StandardError => e
  warn "error: #{e.message}"
  1
end

exit run_cli(ARGV) if __FILE__ == $PROGRAM_NAME
