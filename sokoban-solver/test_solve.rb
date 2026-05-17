require 'minitest/autorun'
require_relative 'solve'

class SokobanSolverTest < Minitest::Test
  LEVEL_ONE = [
    '@@@@@@@@',
    '@@@@@@@@',
    '@@m..@@@',
    '@@x#X.@@',
    '@@..@.@@',
    '@@....@@',
    '@@@@@@@@',
    '@@@@@@@@'
  ].freeze

  def test_solves_known_level
    board = Board.new(LEVEL_ONE)
    solution = board.solve

    assert_predicate solution, :solved?
    assert board.solved_boxes?(solution.states.last.boxes)
    assert_equal 2, solution.states.last.boxes.length
    assert_operator solution.pushes, :>, 0
  end

  def test_reports_no_solution_for_dead_corner_box
    board = Board.new([
      '@@@@@@',
      '@m@@@@',
      '@.#@@@',
      '@...x@',
      '@@@@@@'
    ])

    refute_predicate board.solve, :solved?
  end

  def test_rejects_missing_player
    error = assert_raises(ArgumentError) do
      Board.new([
        '@@@',
        '@#x',
        '@@@'
      ])
    end

    assert_match(/exactly one player/, error.message)
  end

  def test_rejects_unknown_cells
    error = assert_raises(ArgumentError) do
      Board.new([
        '@@@',
        '@m?',
        '@@@'
      ])
    end

    assert_match(/unknown cell/, error.message)
  end

  def test_compatibility_solve_sokoban_wrapper
    board = Board.new(LEVEL_ONE)

    _out, _err = capture_io do
      assert_equal 'Solved', solve_sokoban(board)
    end
  end
end
