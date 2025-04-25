package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

// Fraction представляет обыкновенную дробь с числителем и знаменателем
type Fraction struct {
	numerator   int
	denominator int
}

// Expression представляет математическое выражение, которое может быть
// либо обыкновенной дробью, либо десятичным числом
type Expression struct {
	isFraction bool
	fraction   Fraction
	number     float64
}

// gcd вычисляет наибольший общий делитель двух чисел
func gcd(a, b int) int {
	for b != 0 {
		a, b = b, a%b
	}
	return a
}

// simplify упрощает дробь, деля числитель и знаменатель на их НОД
func simplify(f Fraction) Fraction {
	g := gcd(f.numerator, f.denominator)
	return Fraction{
		numerator:   f.numerator / g,
		denominator: f.denominator / g,
	}
}

// add складывает две дроби
func add(f1, f2 Fraction) Fraction {
	numerator := f1.numerator*f2.denominator + f2.numerator*f1.denominator
	denominator := f1.denominator * f2.denominator
	return simplify(Fraction{numerator, denominator})
}

// subtract вычитает одну дробь из другой
func subtract(f1, f2 Fraction) Fraction {
	numerator := f1.numerator*f2.denominator - f2.numerator*f1.denominator
	denominator := f1.denominator * f2.denominator
	return simplify(Fraction{numerator, denominator})
}

// multiply умножает две дроби
func multiply(f1, f2 Fraction) Fraction {
	numerator := f1.numerator * f2.numerator
	denominator := f1.denominator * f2.denominator
	return simplify(Fraction{numerator, denominator})
}

// divide делит одну дробь на другую
func divide(f1, f2 Fraction) Fraction {
	numerator := f1.numerator * f2.denominator
	denominator := f1.denominator * f2.numerator
	return simplify(Fraction{numerator, denominator})
}

// parseFraction преобразует строку в формате "a/b" в структуру Fraction
func parseFraction(s string) (Fraction, error) {
	parts := strings.Split(s, "/")
	if len(parts) != 2 {
		return Fraction{}, fmt.Errorf("неверный формат дроби")
	}

	var num, denom int
	fmt.Sscanf(parts[0], "%d", &num)
	fmt.Sscanf(parts[1], "%d", &denom)

	if denom == 0 {
		return Fraction{}, fmt.Errorf("знаменатель не может быть нулем")
	}

	return Fraction{num, denom}, nil
}

func parseExpression(s string) (Expression, error) {
	// Проверяем, является ли выражение обыкновенной дробью
	if strings.Contains(s, "/") {
		fraction, err := parseFraction(s)
		if err != nil {
			return Expression{}, err
		}
		return Expression{isFraction: true, fraction: fraction}, nil
	}

	// Пытаемся распарсить как десятичное число
	number, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return Expression{}, fmt.Errorf("неверный формат числа")
	}
	return Expression{isFraction: false, number: number}, nil
}

func calculateExpression(expr1, expr2 Expression, operator string) (Expression, error) {
	if expr1.isFraction != expr2.isFraction {
		return Expression{}, fmt.Errorf("нельзя смешивать дроби и обычные числа")
	}

	if expr1.isFraction {
		var result Fraction
		switch operator {
		case "+":
			result = add(expr1.fraction, expr2.fraction)
		case "-":
			result = subtract(expr1.fraction, expr2.fraction)
		case "*":
			result = multiply(expr1.fraction, expr2.fraction)
		case "/":
			if expr2.fraction.numerator == 0 {
				return Expression{}, fmt.Errorf("деление на ноль")
			}
			result = divide(expr1.fraction, expr2.fraction)
		default:
			return Expression{}, fmt.Errorf("неверный оператор")
		}
		return Expression{isFraction: true, fraction: result}, nil
	} else {
		var result float64
		switch operator {
		case "+":
			result = expr1.number + expr2.number
		case "-":
			result = expr1.number - expr2.number
		case "*":
			result = expr1.number * expr2.number
		case "/":
			if expr2.number == 0 {
				return Expression{}, fmt.Errorf("деление на ноль")
			}
			result = expr1.number / expr2.number
		default:
			return Expression{}, fmt.Errorf("неверный оператор")
		}
		return Expression{isFraction: false, number: result}, nil
	}
}

// solveQuadraticEquation решает квадратное уравнение вида ax² + bx + c = 0
// Возвращает два корня, флаг наличия решения и флаг наличия двух различных корней
func solveQuadraticEquation(a, b, c float64) (float64, float64, bool, bool) {
	// Вычисляем дискриминант
	D := b*b - 4*a*c

	// Если a = 0, уравнение линейное
	if a == 0 {
		if b == 0 {
			return 0, 0, false, false // Нет решений
		}
		return -c / b, 0, true, false // Одно решение
	}

	// Если дискриминант отрицательный, нет действительных корней
	if D < 0 {
		return 0, 0, false, false
	}

	// Если дискриминант равен нулю, один корень
	if D == 0 {
		x := -b / (2 * a)
		return x, x, true, false
	}

	// Если дискриминант положительный, два корня
	x1 := (-b + math.Sqrt(D)) / (2 * a)
	x2 := (-b - math.Sqrt(D)) / (2 * a)
	return x1, x2, true, true
}

// parseCoefficient преобразует строку в числовой коэффициент
// Поддерживает форматы: +2x², -3x², *4x², /2x², +3x, -2x, *4x, /2x, +5, -3, *4, /2
func parseCoefficient(input string) (float64, error) {
	input = strings.TrimSpace(input)

	// Если ввод пустой, возвращаем 0
	if input == "" {
		return 0, nil
	}

	// Определяем операцию и число
	operation := ""
	numberStr := input

	// Проверяем наличие операции в начале строки
	if len(input) > 0 {
		firstChar := string(input[0])
		if firstChar == "+" || firstChar == "-" || firstChar == "*" || firstChar == "/" {
			operation = firstChar
			numberStr = strings.TrimSpace(input[1:])
		}
	}

	// Если после операции осталась пустая строка, возвращаем 0
	if numberStr == "" {
		return 0, nil
	}

	// Проверяем, содержит ли ввод x² или x^2
	if strings.Contains(numberStr, "x²") || strings.Contains(numberStr, "x^2") {
		// Удаляем x² или x^2
		numberStr = strings.ReplaceAll(numberStr, "x²", "")
		numberStr = strings.ReplaceAll(numberStr, "x^2", "")

		// Если после удаления осталась пустая строка, значит был просто x² или x^2
		if numberStr == "" {
			if operation == "-" {
				return -1, nil
			}
			return 1, nil
		}

		// Парсим оставшееся число
		number, err := strconv.ParseFloat(numberStr, 64)
		if err != nil {
			return 0, fmt.Errorf("неверный формат коэффициента")
		}

		// Применяем операцию
		switch operation {
		case "-":
			return -number, nil
		case "*":
			return number, nil
		case "/":
			if number == 0 {
				return 0, fmt.Errorf("деление на ноль")
			}
			return 1 / number, nil
		default:
			return number, nil
		}
	}

	// Если нет x² или x^2, парсим как обычное число
	number, err := strconv.ParseFloat(numberStr, 64)
	if err != nil {
		return 0, fmt.Errorf("неверный формат числа")
	}

	// Применяем операцию
	switch operation {
	case "-":
		return -number, nil
	case "*":
		return number, nil
	case "/":
		if number == 0 {
			return 0, fmt.Errorf("деление на ноль")
		}
		return 1 / number, nil
	default:
		return number, nil
	}
}

// printMenu выводит главное меню программы
func printMenu() {
	fmt.Println("\n=== Калькулятор ===")
	fmt.Println("1. Вычислить выражение с числами (например: 5 + 2 или 5.5 + 2.3)")
	fmt.Println("2. Вычислить выражение с обыкновенными дробями (например: 1/2 + 1/4)")
	fmt.Println("3. Решить квадратное уравнение (ax² + bx + c = 0)")
	fmt.Println("4. Выход")
	fmt.Println("\nСравнение обычных чисел и обыкновенных дробей:")
	fmt.Println("+------------------+------------------+------------------+")
	fmt.Println("| Операция         | Обычные числа    | Обыкновенные дроби |")
	fmt.Println("+------------------+------------------+------------------+")
	fmt.Println("| Сложение (+)     | 5 + 2 = 7        | 1/2 + 1/4 = 3/4  |")
	fmt.Println("| Вычитание (-)    | 5 - 2 = 3        | 1/2 - 1/4 = 1/4  |")
	fmt.Println("| Умножение (*)    | 5 * 2 = 10       | 1/2 * 1/4 = 1/8  |")
	fmt.Println("| Деление (/)      | 5 / 2 = 2.5      | 1/2 / 1/4 = 2    |")
	fmt.Println("+------------------+------------------+------------------+")
	fmt.Print("Выберите операцию (1-4): ")
}

func main() {
	emptyInputs := 0
	reader := bufio.NewReader(os.Stdin)

	for {
		printMenu()

		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)

		if input == "" {
			emptyInputs++
			if emptyInputs >= 3 {
				fmt.Println("Программа завершена из-за трех пустых вводов подряд.")
				os.Exit(0)
			}
			continue
		}

		emptyInputs = 0

		choice := 0
		fmt.Sscanf(input, "%d", &choice)

		if choice == 4 {
			fmt.Println("До свидания!")
			return
		}

		if choice < 1 || choice > 3 {
			fmt.Println("Неверный выбор! Попробуйте снова.")
			continue
		}

		if choice == 3 {
			var a, b, c float64
			var err error

			fmt.Print("\nВведите коэффициент a (например: +2x², -3x², *4x², /2x²): ")
			input, _ = reader.ReadString('\n')
			a, err = parseCoefficient(input)
			if err != nil {
				fmt.Printf("Ошибка: %v\n", err)
				continue
			}

			fmt.Print("Введите коэффициент b (например: +3x, -2x, *4x, /2x): ")
			input, _ = reader.ReadString('\n')
			b, err = parseCoefficient(strings.ReplaceAll(input, "x", ""))
			if err != nil {
				fmt.Printf("Ошибка: %v\n", err)
				continue
			}

			fmt.Print("Введите коэффициент c (например: +5, -3, *4, /2): ")
			input, _ = reader.ReadString('\n')
			c, err = parseCoefficient(input)
			if err != nil {
				fmt.Printf("Ошибка: %v\n", err)
				continue
			}

			// Выводим уравнение в красивом формате
			fmt.Printf("\nУравнение: ")
			if a != 0 {
				if a == 1 {
					fmt.Print("x²")
				} else if a == -1 {
					fmt.Print("-x²")
				} else {
					fmt.Printf("%.0fx²", a)
				}
			}

			if b != 0 {
				if b > 0 && a != 0 {
					fmt.Print(" + ")
				}
				if b == 1 {
					fmt.Print("x")
				} else if b == -1 {
					fmt.Print("-x")
				} else {
					fmt.Printf("%.0fx", b)
				}
			}

			if c != 0 {
				if c > 0 && (a != 0 || b != 0) {
					fmt.Print(" + ")
				}
				fmt.Printf("%.0f", c)
			}
			fmt.Println(" = 0")

			x1, x2, hasSolution, hasTwoSolutions := solveQuadraticEquation(a, b, c)

			if !hasSolution {
				if a == 0 && b == 0 {
					fmt.Println("Уравнение не имеет решений")
				} else {
					fmt.Println("Уравнение не имеет действительных корней")
				}
			} else if !hasTwoSolutions {
				if a == 0 {
					fmt.Printf("Уравнение имеет одно решение: x = %.2f\n", x1)
				} else {
					fmt.Printf("Уравнение имеет один корень: x = %.2f\n", x1)
				}
			} else {
				fmt.Printf("Уравнение имеет два корня: x1 = %.2f, x2 = %.2f\n", x1, x2)
			}

			fmt.Print("\nНажмите Enter для продолжения...")
			reader.ReadString('\n')
			continue
		}

		var expr string
		if choice == 1 {
			fmt.Print("\nВведите выражение с числами (например: 5 + 2 или 5.5 + 2.3): ")
		} else {
			fmt.Print("\nВведите выражение с обыкновенными дробями (например: 1/2 + 1/4): ")
		}
		expr, _ = reader.ReadString('\n')
		expr = strings.TrimSpace(expr)

		// Разбиваем выражение на части
		parts := strings.Fields(expr)
		if len(parts) != 3 {
			fmt.Println("Неверный формат выражения! Используйте формат: число оператор число")
			continue
		}

		expr1, err := parseExpression(parts[0])
		if err != nil {
			fmt.Printf("Ошибка в первом числе: %v\n", err)
			continue
		}

		expr2, err := parseExpression(parts[2])
		if err != nil {
			fmt.Printf("Ошибка во втором числе: %v\n", err)
			continue
		}

		// Проверяем соответствие выбранного типа и введенных чисел
		if (choice == 1 && expr1.isFraction) || (choice == 2 && !expr1.isFraction) {
			fmt.Println("Ошибка: несоответствие типа чисел выбранному режиму!")
			continue
		}

		result, err := calculateExpression(expr1, expr2, parts[1])
		if err != nil {
			fmt.Printf("Ошибка вычисления: %v\n", err)
			continue
		}

		if result.isFraction {
			fmt.Printf("\nРезультат: %d/%d %s %d/%d = %d/%d\n",
				expr1.fraction.numerator, expr1.fraction.denominator,
				parts[1],
				expr2.fraction.numerator, expr2.fraction.denominator,
				result.fraction.numerator, result.fraction.denominator)
		} else {
			// Определяем количество знаков после запятой для вывода
			precision := 0
			if strings.Contains(parts[0], ".") || strings.Contains(parts[2], ".") {
				precision = 2
			}
			format := fmt.Sprintf("\nРезультат: %%.%df %%s %%.%df = %%.%df\n", precision, precision, precision)
			fmt.Printf(format,
				expr1.number,
				parts[1],
				expr2.number,
				result.number)
		}

		fmt.Print("\nНажмите Enter для продолжения...")
		reader.ReadString('\n')
	}
}

// Напишите go build main.go чтобы собрать программу
