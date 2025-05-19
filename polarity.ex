defmodule Polarity do

  @moduledoc """
    Add your solver function below. You may add additional helper functions if you desire. 
    Test your code by running 'mix test --seed 0' from the simple_tester_ex directory.
  """

  def polarity(board, specs) do
    new_board = update_with_xs(board, specs)
    solve_magnets(new_board, specs, 0, 0, getChar(new_board, 0, 0), true, false)
  end

  def getChar(rules, i, j) do String.at(elem(rules, i), j) end

  def solve_magnets(rules, _, _, _, _, _, true) do fill_empty_cells(rules) end
  def solve_magnets(_, _, _, _, _, false, _) do 
    nil end
  def solve_magnets(rules, constraints, i, j, _, _, _) when (j == byte_size(elem(rules,0)) and (i == tuple_size(rules)-1)) do 
    solve_magnets(rules, constraints, 0, 0, getChar(rules, 0, 0), false, is_done(constraints)) 
  end
  def solve_magnets(rules, constraints, i, j, _, _, _) when (j >= byte_size(elem(rules,0))) do 
    solve_magnets(rules, constraints, i+1, 0, getChar(rules, i+1, 0), true, false) 
  end
  def solve_magnets(rules, constraints, i, j, currElem, _, _) when (currElem == "T") do 
    sol = cond do
      !can_put_pattern_vertically(rules, constraints, i, j, "+-") -> nil
      true -> solve_magnets(update_with_xs(place_pattern_vertically(rules, i, j, "+-"), constraints), adjust_requirements_vertically(constraints, i, j, "+-"), i, j + 1, getChar(place_pattern_vertically(rules, i, j, "+-"), i, j+1), is_solvable(update_with_xs(place_pattern_vertically(rules, i, j, "+-"), adjust_requirements_vertically(constraints, i, j, "+-")), adjust_requirements_vertically(constraints, i, j, "+-")), is_done(adjust_requirements_vertically(constraints, i, j, "+-")))
    end
    if sol == nil do
      sol = cond do
        !can_put_pattern_vertically(rules, constraints, i, j, "-+") -> nil
        true -> solve_magnets(update_with_xs(place_pattern_vertically(rules, i, j, "-+"), constraints), adjust_requirements_vertically(constraints, i, j, "-+"), i, j + 1, getChar(place_pattern_vertically(rules, i, j, "-+"), i, j+1), is_solvable(update_with_xs(place_pattern_vertically(rules, i, j, "-+"), adjust_requirements_vertically(constraints, i, j, "-+")), adjust_requirements_vertically(constraints, i, j, "-+")), is_done(adjust_requirements_vertically(constraints, i, j, "-+")))
      end
      if sol == nil do
        solve_magnets(update_with_xs(place_pattern_vertically(rules, i, j, "XX"), constraints), constraints, i, j + 1, getChar(place_pattern_vertically(rules, i, j, "XX"), i, j+1), is_solvable(place_pattern_vertically(rules, i, j, "XX"), constraints), is_done(constraints))
      else
        sol
      end
    else
      sol
    end
  end

  def solve_magnets(rules, constraints, i, j, currElem, _, _) when (currElem == "L") do
    sol = cond do
      !can_put_pattern_horizontally(rules, constraints, i, j, "+-") -> nil
      true -> solve_magnets(update_with_xs(place_pattern_horizontally(rules, i, j, "+-"), adjust_requirements_horizontally(constraints, i, j, "+-")), adjust_requirements_horizontally(constraints, i, j, "+-"), i, j + 2, getChar(rules, i, j+2), is_solvable(update_with_xs(place_pattern_horizontally(rules, i, j, "+-"), adjust_requirements_horizontally(constraints, i, j, "+-")), adjust_requirements_horizontally(constraints, i, j, "+-")), is_done(adjust_requirements_horizontally(constraints, i, j, "+-")))
    end
    if sol == nil do
      sol = cond do
        !can_put_pattern_horizontally(rules, constraints, i, j, "-+") -> nil
        true -> solve_magnets(update_with_xs(place_pattern_horizontally(rules, i, j, "-+"), adjust_requirements_horizontally(constraints, i, j, "-+")), adjust_requirements_horizontally(constraints, i, j, "-+"), i, j + 2, getChar(rules, i, j+2), is_solvable(update_with_xs(place_pattern_horizontally(rules, i, j, "-+"), adjust_requirements_horizontally(constraints, i, j, "-+")), adjust_requirements_horizontally(constraints, i, j, "-+")), is_done(adjust_requirements_horizontally(constraints, i, j, "-+")))
      end
      if sol == nil do
        solve_magnets(update_with_xs(place_pattern_horizontally(rules, i, j, "XX"), constraints), constraints, i, j + 2, getChar(update_with_xs(place_pattern_horizontally(rules, i, j, "XX"), constraints), i, j+2), is_solvable(update_with_xs(place_pattern_horizontally(rules, i, j, "XX"), constraints), constraints), is_done(constraints))          
      else
        sol
      end
    else
      sol
    end
  end

  def solve_magnets(rules, constraints, i, j, _, _, _) do 
  solve_magnets(rules, constraints, i, j+1, getChar(rules, i, j+1), true, false) end

  def place_pattern_vertically(rules, i, j, pat) do replace_char(replace_char(rules, i+1, j, String.at(pat, 1)), i, j, String.at(pat, 0)) end
  def place_pattern_horizontally(rules, i, j, pat) do replace_char(replace_char(rules, i, j+1, String.at(pat, 1)), i, j, String.at(pat, 0)) end

  def can_put_pattern_vertically(rules, constraints, i, j, pat) do
    right = Map.get(constraints, "right")
    left = Map.get(constraints, "left")
    top = Map.get(constraints, "top")
    bottom = Map.get(constraints, "bottom")

    first = String.at(pat, 0)
    second = String.at(pat, 1)
    cond do
      first == "+" and (elem(top, j) == 0 or elem(left, i) == 0 or elem(bottom, j) == 0 or elem(right, i + 1) == 0) -> false
      first == "-" and (elem(top, j) == 0 or elem(left, i + 1) == 0 or elem(bottom, j) == 0 or elem(right, i) == 0) -> false
      j > 0 and (String.at(elem(rules, i), (j - 1)) == first or String.at(elem(rules, (i + 1)), (j - 1)) == second) -> false
      j < String.length(elem(rules, 0)) - 1 and (String.at(elem(rules, i), (j + 1)) == first or String.at(elem(rules, (i + 1)), (j + 1)) == second) -> false
      i > 0 and String.at(elem(rules, i-1), j) == first -> false
      i + 2 < tuple_size(rules) and String.at(elem(rules, (i + 2)), j) == second -> false
      true -> true
    end
  end

  def can_put_pattern_horizontally(rules, constraints, i, j, pat) do
    right = Map.get(constraints, "right")
    left = Map.get(constraints, "left")
    top = Map.get(constraints, "top")
    bottom = Map.get(constraints, "bottom")

    first = String.at(pat, 0)
    second = String.at(pat, 1)

    cond do
      first == "+" and (elem(top, j) == 0 or elem(left, i) == 0 or elem(bottom, j + 1) == 0 or elem(right, i) == 0) -> false
      first == "-" and (elem(top, j + 1) == 0 or elem(left, i) == 0 or elem(bottom, j) == 0 or elem(right, i) == 0) -> false
      i > 0 and (String.at(elem(rules, i - 1), j) == first or String.at(elem(rules, i - 1), j + 1) == second) -> false
      i < tuple_size(rules) - 1 and (String.at(elem(rules, i + 1), j) == first or String.at(elem(rules, i + 1), j + 1) == second) -> false
      j > 0 and String.at(elem(rules, i), j - 1) == first -> false
      j + 2 < String.length(elem(rules, 0)) and String.at(elem(rules, i), j + 2) == second -> false
      true -> true
    end
  end

  def is_done(constraints) do
    right = Map.get(constraints, "right")
    left = Map.get(constraints, "left")
    top = Map.get(constraints, "top")
    bottom = Map.get(constraints, "bottom")
    cond do
      Enum.any?(Tuple.to_list(left), fn element -> element > 0 end) -> false
      Enum.any?(Tuple.to_list(right), fn element -> element > 0 end) -> false
      Enum.any?(Tuple.to_list(top), fn element -> element > 0 end) -> false
      Enum.any?(Tuple.to_list(bottom), fn element -> element > 0 end) -> false
      true -> true
    end
  end

  def adjust_requirements_horizontally(constraints, i, j, pat) do
    right = Map.get(constraints, "right")
    left = Map.get(constraints, "left")
    top = Map.get(constraints, "top")
    bottom = Map.get(constraints, "bottom")

    first = String.at(pat, 0)

    cond do
      first == "+" ->
        %{
          constraints |
          "top" => put_elem(top, j, elem(top, j) - 1),
          "left" => put_elem(left, i, elem(left, i) - 1),
          "bottom" => put_elem(bottom, j + 1, elem(bottom, j + 1) - 1),
          "right" => put_elem(right, i, elem(right, i) - 1)
        }

      first == "-" ->
        %{
          constraints |
          "top" => put_elem(top, j + 1, elem(top, j + 1) - 1),
          "left" => put_elem(left, i, elem(left, i) - 1),
          "bottom" => put_elem(bottom, j, elem(bottom, j) - 1),
          "right" => put_elem(right, i, elem(right, i) - 1)
        }

      true -> constraints
    end
  end

  def adjust_requirements_vertically(constraints, i, j, pat) do
    right = Map.get(constraints, "right")
    left = Map.get(constraints, "left")
    top = Map.get(constraints, "top")
    bottom = Map.get(constraints, "bottom")

    first = String.at(pat, 0)

    cond do
      first == "+" ->
        %{
          constraints |
          "top" => put_elem(top, j, elem(top, j) - 1),
          "left" => put_elem(left, i, elem(left, i) - 1),
          "bottom" => put_elem(bottom, j, elem(bottom, j) - 1),
          "right" => put_elem(right, i + 1, elem(right, i + 1) - 1)
        }

      first == "-" ->
        %{
          constraints |
          "top" => put_elem(top, j, elem(top, j) - 1),
          "left" => put_elem(left, i + 1, elem(left, i + 1) - 1),
          "bottom" => put_elem(bottom, j, elem(bottom, j) - 1),
          "right" => put_elem(right, i, elem(right, i) - 1)
        }

      true -> constraints
    end
  end

  def update_with_xs(rules, constraints) do
    right = Map.get(constraints, "right")
    left = Map.get(constraints, "left")
    top = Map.get(constraints, "top")
    bottom = Map.get(constraints, "bottom")
    update_columns_with_xs(update_rows_with_xs(rules, left, right), top, bottom)
  end


  def update_rows_with_xs(rules, left, right) do update_rows_with_xs(rules, Tuple.to_list(left), Tuple.to_list(right), 0) end
  def update_rows_with_xs(rules, [lh], [rh], row_num) when (lh ==0 and rh == 0) do update_row_with_xs_both(rules, row_num) end
  def update_rows_with_xs(rules, [lh], [rh], row_num) when (lh ==0 or rh == 0) do update_row_with_xs_either(rules, row_num) end
  def update_rows_with_xs(rules, [lh|lt], [rh|rt], row_num) when (lh ==0 and rh == 0) do update_rows_with_xs(update_row_with_xs_both(rules, row_num), lt, rt, row_num+1) end
  def update_rows_with_xs(rules, [lh, lh2|lt], [rh, rh2|rt], row_num) when (((lh == lh2) and (lh == 0)) or ((rh == rh2) and (rh == 0))) do update_rows_with_xs(update_row_with_xs_doubles(update_row_with_xs_either(rules, row_num), row_num), [lh2|lt], [rh2|rt], row_num+1) end
  def update_rows_with_xs(rules, [lh|lt], [rh|rt], row_num) when (lh ==0 or rh == 0) do update_rows_with_xs(update_row_with_xs_either(rules, row_num), lt, rt, row_num+1) end

  def update_rows_with_xs(rules, [_], [_], _) do rules end  
  def update_rows_with_xs(rules, [_lh|lt], [_rh|rt], row_num) do update_rows_with_xs(rules, lt, rt, row_num+1) end  

  def update_columns_with_xs(rules, top, bottom) do update_columns_with_xs(rules, Tuple.to_list(top), Tuple.to_list(bottom), 0) end
  def update_columns_with_xs(rules, [th], [bh], col_num) when (th == 0 and bh == 0) do update_column_with_xs_both(rules, col_num) end
  def update_columns_with_xs(rules, [th], [bh], col_num) when (th == 0 or bh == 0) do update_column_with_xs_either(rules, col_num) end
  def update_columns_with_xs(rules, [th|tt], [bh|bt], col_num) when (th ==0 and bh == 0) do update_columns_with_xs(update_column_with_xs_both(rules, col_num), tt, bt, col_num+1) end

  def update_columns_with_xs(rules, [th, th2|tt], [bh, bh2|bt], col_num) when ((th == th2) and (th == 0)) or ((bh == bh2) and (bh == 0)) do update_columns_with_xs(update_column_with_xs_doubles(update_column_with_xs_either(rules, col_num), col_num), [th2|tt], [bh2|bt], col_num+1) end
  def update_columns_with_xs(rules, [th|tt], [bh|bt], col_num) when (th ==0 or bh == 0) do update_columns_with_xs(update_column_with_xs_either(rules, col_num), tt, bt, col_num+1) end
  def update_columns_with_xs(rules, [_], [_], _) do rules end  
  def update_columns_with_xs(rules, [_th|tt], [_bh|bt], col_num) do update_columns_with_xs(rules, tt, bt, col_num+1) end  

  def update_row_with_xs_both(rules, row_num) do update_row_with_xs_both(rules, String.codepoints(elem(rules, row_num)), row_num, 0) end
  def update_row_with_xs_both(rules, [hd|tl], i, j) when (hd == "T") do
    update_row_with_xs_both(place_pattern_vertically(rules, i, j, "XX"), tl, i, j+1)
  end
  def update_row_with_xs_both(rules, [hd|tl], i, j) when (hd == "B") do
    update_row_with_xs_both(place_pattern_vertically(rules, i-1, j, "XX"), tl, i, j+1)
  end
  def update_row_with_xs_both(rules, [hd,_|tl], i, j) when (hd == "L") do
    update_row_with_xs_both(place_pattern_horizontally(rules, i, j, "XX"), tl, i, j+2)
  end
  def update_row_with_xs_both(rules, [_|tl], i, j) do
    update_row_with_xs_both(rules, tl, i, j+1)
  end
  def update_row_with_xs_both(rules, [], _, _) do rules end

  def update_row_with_xs_doubles(rules, row_num) do 
    update_row_with_xs_doubles(rules, String.codepoints(elem(rules, row_num)), row_num, 0) end
  def update_row_with_xs_doubles(rules, [hd|tl], i, j) when hd == "T" do
    update_row_with_xs_doubles(place_pattern_vertically(rules, i, j, "XX"), tl, i, j+1) 
  end
  def update_row_with_xs_doubles(rules, [_hd|tl], i, j) do
    update_row_with_xs_doubles(rules, tl, i, j+1) 
  end  
  def update_row_with_xs_doubles(rules, [], _, _) do rules end
  
  def update_row_with_xs_either(rules, row_num) do update_row_with_xs_either(rules, String.codepoints(elem(rules, row_num)), row_num, 0) end
  def update_row_with_xs_either(rules, [hd,_|tl], i, j) when (hd == "L") do
    update_row_with_xs_either(place_pattern_horizontally(rules, i, j, "XX"), tl, i, j+2)
  end
  def update_row_with_xs_either(rules, [_|tl], i, j) do
    update_row_with_xs_either(rules, tl, i, j+1)
  end
  def update_row_with_xs_either(rules, [], _, _) do rules end


  def get_col_char_list(rules, col) do get_col_char_list(Tuple.to_list(rules), 0, col, []) end
  def get_col_char_list([hd|tl], row, col, acc) do get_col_char_list(tl, row+1, col, acc ++ [String.at(hd,col)]) end
  def get_col_char_list([], _, _, acc ) do acc end

  def update_column_with_xs_both(rules, col_num) do update_column_with_xs_both(rules, get_col_char_list(rules, col_num), 0, col_num) end
  def update_column_with_xs_both(rules, [hd|tl], i, j) when (hd == "L") do
    update_column_with_xs_both(place_pattern_horizontally(rules, i, j, "XX"), tl, i+1, j)
  end
  def update_column_with_xs_both(rules, [hd|tl], i, j) when (hd == "R") do
    update_column_with_xs_both(place_pattern_horizontally(rules, i, j-1, "XX"), tl, i+1, j)
  end
  def update_column_with_xs_both(rules, [hd,_|tl], i, j) when (hd == "T") do
    update_column_with_xs_both(place_pattern_vertically(rules, i, j, "XX"), tl, i+2, j)
  end
  def update_column_with_xs_both(rules, [_|tl], i, j) do
    update_column_with_xs_both(rules, tl, i+1, j)
  end
  def update_column_with_xs_both(rules, [], _, _) do rules end

  def update_column_with_xs_doubles(rules, col_num) do update_column_with_xs_doubles(rules, get_col_char_list(rules, col_num), 0, col_num) end
  def update_column_with_xs_doubles(rules, [hd|tl], i, j) when hd == "L" do
    update_column_with_xs_doubles(place_pattern_horizontally(rules, i, j, "XX"), tl, i+1, j)
  end
  def update_column_with_xs_doubles(rules, [_hd|tl], i, j) do
    update_column_with_xs_doubles(rules, tl, i+1, j)
  end
  def update_column_with_xs_doubles(rules, [], _, _) do rules end
  
  def update_column_with_xs_either(rules, col_num) do update_column_with_xs_either(rules, get_col_char_list(rules, col_num), 0, col_num) end
  def update_column_with_xs_either(rules, [hd,_|tl], i, j) when (hd == "T") do
    update_column_with_xs_either(place_pattern_vertically(rules, i, j, "XX"), tl, i+2, j)
  end
  def update_column_with_xs_either(rules, [_|tl], i, j) do
    update_column_with_xs_either(rules, tl, i+1, j)
  end
  def update_column_with_xs_either(rules, [], _, _) do rules end


  defp replace_char(rules, i, j, new_char) do
    row = elem(rules, i)
    updated_row = String.slice(row, 0, j) <> new_char <> String.slice(row, j + 1, String.length(row) - j - 1)
    put_elem(rules, i, updated_row)
  end

  def fill_empty_cells(rules) do fill_empty_cells(Tuple.to_list(rules), []) end
  def fill_empty_cells([hd|tl], acc) do fill_empty_cells(tl, acc ++ [List.to_string(fill_row(hd))]) end
  def fill_empty_cells([], acc) do List.to_tuple(acc) end
  def fill_row(str) do fill_row(String.split(str, "", trim: true), []) end
  def fill_row([hd|tl], acc) when hd == "L" or hd == "R" or hd == "T" or hd == "B" do fill_row(tl, acc ++ ["X"]) end
  def fill_row([hd|tl], acc) do fill_row(tl, acc ++ [hd]) end
  def fill_row([], acc) do acc end
  def fill_row(_,_) do nil end
  
  def is_solvable(rules, constraints) do 
    is_solvable_LR(rules, constraints, tuple_size(rules), 0, true) and is_solvable_TB(rules, constraints, String.length(elem(rules, 0)), 0, true) end
  def final_score(p, n, p_offset, n_offset, score) do not ((p >= 0 and score-p_offset < p) or (n >= 0 and score-n_offset < n)) end

  def is_solvable_LR(_rules, _constraints, _length, _row, false) do false end
  def is_solvable_LR(rules, constraints, length, row, acc) when row != length do 
    is_solvable_LR(rules, constraints, length, row+1, acc and is_solvable_row(rules, String.codepoints(elem(rules, row)), row, 0, constraints, elem(Map.get(constraints, "left"), row), elem(Map.get(constraints, "right"), row), 0, 0, 0)) 
  end
  def is_solvable_LR(_rules, _constraints, _length, _row, acc) do acc end

  def is_solvable_row(_rules, [], _i, _j, _constraints, p, n, p_offset, n_offset, score) do 
    final_score(p, n, p_offset, n_offset, score) end
  def is_solvable_row(rules, [hd|tl], i, j, constraints, p, n, p_offset, n_offset, score) when (hd == "R") do is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset, n_offset, score+0.5) end
  def is_solvable_row(rules, [hd|tl], i, j, constraints, p, n, p_offset, n_offset, score) when (hd == "L") do 
    if (!can_put_pattern_horizontally(rules, constraints, i, j, "+-") and !can_put_pattern_horizontally(rules, constraints, i, j, "-+")) do
      is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset+1, n_offset+1, score+0.5)
    else
      is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset, n_offset, score+0.5)
    end
  end
  def is_solvable_row(rules, [hd|tl], i, j, constraints, p, n, p_offset, n_offset, score) when (hd == "T") do 
    can_put_MP = can_put_pattern_vertically(rules, constraints, i, j, "-+")
    can_put_PM = can_put_pattern_vertically(rules, constraints, i, j, "+-")
    cond do
      !can_put_MP and !can_put_PM -> is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset+1, n_offset+1, score+1) 
      !can_put_MP -> is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset, n_offset+1, score+1) 
      !can_put_PM -> is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset+1, n_offset, score+1)
      true ->  is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset, n_offset, score+1)
    end
  end
  def is_solvable_row(rules, [hd|tl], i, j, constraints, p, n, p_offset, n_offset, score) when (hd == "B") do 
    can_put_MP = can_put_pattern_vertically(rules, constraints, i-1, j, "-+")
    can_put_PM = can_put_pattern_vertically(rules, constraints, i-1, j, "+-")
    cond do
      !can_put_MP and !can_put_PM -> is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset+1, n_offset+1, score+1) 
      !can_put_MP -> is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset+1, n_offset, score+1) 
      !can_put_PM -> is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset, n_offset+1, score+1)
      true ->  is_solvable_row(rules, tl, i, j+1, constraints, p, n, p_offset, n_offset, score+1)
    end
  end
  def is_solvable_row(rules, [_hd|tl], i, j, constraints, p_spec, n_spec, p_offset, n_offset, score) do is_solvable_row(rules, tl, i, j+1, constraints, p_spec, n_spec, p_offset, n_offset, score) end



  def col_string([], _col, acc) do acc end
  def col_string([hd|tl], col, acc) do col_string(tl, col,  acc ++ [String.at(hd, col)]) end
  def col_string(rules, col) do col_string(Tuple.to_list(rules), col, []) end

  def is_solvable_TB(_rules, _constraints, _length, _col, false) do false end
  def is_solvable_TB(rules, constraints, length, col, acc) when col != length do 
    is_solvable_TB(rules, constraints, length, col+1, acc and is_solvable_col(rules, col_string(rules, col), 0, col, constraints, elem(Map.get(constraints, "top"), col), elem(Map.get(constraints, "bottom"), col), 0, 0, 0)) end
  def is_solvable_TB(_rules, _constraints, _length, _col, acc) do acc end

  def is_solvable_col(_rules, [], _i, _j, _constraints, p, n, p_offset, n_offset, score) do 
    final_score(p, n, p_offset, n_offset, score) end
  def is_solvable_col(rules, [hd|tl], i, j, constraints, p, n, p_offset, n_offset, score) when (hd == "B") do 
        is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset, n_offset, score+0.5)
  end
  def is_solvable_col(rules, [hd|tl], i, j, constraints, p, n, p_offset, n_offset, score) when (hd == "T") do 
    if (!can_put_pattern_vertically(rules, constraints, i, j, "+-") and !can_put_pattern_vertically(rules, constraints, i, j, "-+")) do
      is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset+1, n_offset+1, score+0.5)
    else
      is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset, n_offset, score+0.5)
    end
  end
  def is_solvable_col(rules, [hd|tl], i, j, constraints, p, n, p_offset, n_offset, score) when (hd == "L") do 
    can_put_MP = can_put_pattern_horizontally(rules, constraints, i, j, "-+")
    can_put_PM = can_put_pattern_horizontally(rules, constraints, i, j, "+-")
    cond do
      !can_put_MP and !can_put_PM -> is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset+1, n_offset+1, score+1) 
      !can_put_MP -> is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset, n_offset+1, score+1) 
      !can_put_PM -> is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset+1, n_offset, score+1)
      true ->  is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset, n_offset, score+1)
    end
  end
  def is_solvable_col(rules, [hd|tl], i, j, constraints, p, n, p_offset, n_offset, score) when (hd == "R") do 
    can_put_MP = can_put_pattern_horizontally(rules, constraints, i, j-1, "-+")
    can_put_PM = can_put_pattern_horizontally(rules, constraints, i, j-1, "+-")
    cond do
      !can_put_MP and !can_put_PM -> is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset+1, n_offset+1, score+1) 
      !can_put_MP -> is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset+1, n_offset, score+1) 
      !can_put_PM -> is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset, n_offset+1, score+1)
      true ->  is_solvable_col(rules, tl, i+1, j, constraints, p, n, p_offset, n_offset, score+1)
    end
  end
  def is_solvable_col(rules, [_hd|tl], i, j, constraints, p_spec, n_spec, p_offset, n_offset, score) do is_solvable_col(rules, tl, i+1, j, constraints, p_spec, n_spec, p_offset, n_offset, score) end
  
end
