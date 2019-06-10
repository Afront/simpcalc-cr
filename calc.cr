class String
  def is_i?
    /\A[-+]?\d+\z/ === self
  end
end

def calculator(input_expression : String)
  numList = Array(Float64).new
  numTemp = Array(Int32 | Char).new
  opList = Array(Char).new
  operations = ['(', ')', '^', '*', '/', '+', '-', '!']
  digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  i = 0

  input_expression = '0' + input_expression if input_expression[0] == '-' || input_expression[0] == '+'

  while i < input_expression.bytesize
    if digits.includes? input_expression[i]
      numTemp.push(input_expression[i].to_i)
    elsif operations.includes? input_expression[i]
      opList.push(input_expression[i])
      unless numTemp.empty?
        numList.push(numTemp.join.to_f64)
        numTemp.clear
      end
    elsif input_expression[i] == '.'
      numTemp.push(input_expression[i])
    else
      puts "Error: Operation #{input_expression[i]} is not recognized."
      return 0.0
    end
    i += 1
  end
  numList.push(numTemp.join.to_f64) unless numTemp.empty?
  result = solver(numList, opList)
  return result
end

def solver(numList : Array(Int | Float), opList : Array(Char))
  op_i = 0
  while op_i < opList.size # && (opList.includes? '(' || opList.includes? ')')
    op = opList[op_i]
    if op == '('
      brackets = -1
      opList.delete_at(op_i)
      numListTemp = Array(Float64).new
      opListTemp = Array(Char).new
      while brackets != 0
        op = opList[op_i]
        print op
        if op == ')' || op == '('
          if op == ')'
            if brackets == -1
              numListTemp.push numList[op_i]
              numList.delete_at(op_i)
              opList.delete_at(op_i)
              break
            end
            brackets += 1
          elsif op == '('
            brackets -= 1
          end
          opListTemp.push opList[op_i]
          opList.delete_at(op_i)
        else
          numListTemp.push numList[op_i]
          numList.delete_at(op_i)
          opListTemp.push opList[op_i]
          opList.delete_at(op_i)
        end
      end
      numList.insert(op_i, solver(numListTemp, opListTemp))
    end

    puts()
    op_i += 1
  end

  # !
  op_i = 0
  while op_i < opList.size # && (opList.includes? '*' || opList.includes? '/')
    op = opList[op_i]
    next op_i += 1 unless op == '!'
    if op == '!'
      numList[op_i] = Math.gamma(numList[op_i] + 1)
      opList.delete_at(op_i)
    else
      print "Error: This error should not exist!"
    end
  end

  # ^
  op_i = 0
  while op_i < opList.size # && (opList.includes? '*' || opList.includes? '/')
    op = opList[op_i]
    next op_i += 1 unless op == '^'
    if op == '^'
      numList[op_i] = numList[op_i] ** numList[op_i + 1]
      numList.delete_at(op_i + 1)
      opList.delete_at(op_i)
    else
      print "Error: This error should not exist!"
    end
  end

  # # */
  op_i = 0
  while op_i < opList.size # && (opList.includes? '*' || opList.includes? '/')
    op = opList[op_i]
    next op_i += 1 unless op == '*' || op == '/'
    if op == '*'
      numList[op_i] *= numList[op_i + 1]
      numList.delete_at(op_i + 1)
      opList.delete_at(op_i)
    elsif op == '/'
      numList[op_i] /= numList[op_i + 1]
      numList.delete_at(op_i + 1)
      opList.delete_at(op_i)
    else
      print "Error: This error should not exist!"
    end
  end

  # + -
  op_i = 0
  while op_i < opList.size
    op = opList[op_i]
    # next op_i += 1 unless op == '+' || op == '-'
    if op == '+'
      numList[op_i] += numList[op_i + 1]
      numList.delete_at(op_i + 1)
      opList.delete_at(op_i)
    elsif op == '-'
      numList[op_i] -= numList[op_i + 1]
      numList.delete_at(op_i + 1)
      opList.delete_at(op_i)
    else
      print "Error: This error should not exist!"
    end
  end
  return numList[0]
end

puts "\e[H\e[2J"
puts "Welcome! This is a calculator"
program = true
answer = Array(Float64).new
n = 0
while (program)
  puts "Please enter an expression!"
  input_expression = gets.to_s.chomp.gsub(/\s+/, "")
  if input_expression == "q" || input_expression == "quit" || input_expression == "exit"
    break
  elsif input_expression == "history" || input_expression == "h"
    next puts answer unless answer.empty?
    next puts "ERROR: History is empty!"
  elsif input_expression == "clear" || input_expression == "cls"
    next puts "\e[H\e[2J"
  end
  result = calculator(input_expression)
  if result
    answer.push result
    puts answer[n]
    n += 1
  end
end

puts "Goodbye!"
