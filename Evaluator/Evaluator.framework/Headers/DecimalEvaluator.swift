//
//  DecimalEvaluator.swift
//  LineCal
//
//  Created by tony on 2023/4/5.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation


/// 大数字计算器
public class DecimalEvaluator : AbstractEvaluator<NSDecimalNumber> {
 
    /// The order or operations (operator precedence) is not clearly defined, especially between the unary minus operator and exponentiation operator (see <a /// href="http://en.wikipedia.org/wiki/Order_of_operations#Exceptions_to_the_standard">http://en.wikipedia.org/wiki/Order_of_operations</a>).
    /// These constants define the operator precedence styles.
    enum Style {
        
        ///  The most commonly operator precedence, where the unary minus as a lower precedence than the exponentiation. With this style, used by Google, Wolfram alpha, and many others, -2^2=-4.
        case STANDARD
        
        /// The operator precedence used by Excel, or bash shell script language, where the unary minus as a higher precedence than the exponentiation. With this style, -2^2=4.
        case EXCEL
    }
    
    // 常量E
    public static let CONSTANT_E = 2.718281828459045
    /** A constant that represents pi (3.14159...) */
    public static let PI = EvaluatorConstant("pi")
    public static let PI2 = EvaluatorConstant("π")
    /** A constant that represents e (2.718281...) */
    public static let E = EvaluatorConstant("e")
    
    /** Returns the smallest integer &gt;= argument */
    public static let CEIL = Function("ceil", 1)
    /** Returns the largest integer &lt;= argument */
    public static let FLOOR = Function("floor", 1)
    /** Returns the closest integer of a number */
    public static let ROUND = Function("round", 1)
    /** Returns the absolute value of a number */
    public static let ABS = Function("abs", 1)

    /** Returns the trigonometric sine of an angle. The angle is expressed in radian.
     正弦函数 sinθ=y/r*/
    public static let SIN = Function("sin", 1)
    /** Returns the trigonometric cosine of an angle. The angle is expressed in radian.
     余弦函数 cosθ=x/r*/
    public static let COS = Function("cos", 1)
    /** Returns the trigonometric tangent of an angle. The angle is expressed in radian.
     正切函数 tanθ=y/x [角度] =（-1， 1）90度没有意义 tan15°，2-√3，tan30°，√3/3， tan45°, 1, tan60°, √3, tan75°, 2+√3*/
    public static let TAN = Function("tan", 1)
    /** 余切 余切函数 cotθ=x/y（正切的倒数） */
    public static let COT = Function("cot", 1)
    /** Returns the trigonometric arc-sine of an angle. The angle is expressed in radian.*/
    public static let ASIN = Function("asin", 1)
    public static let ASIN2 = Function("arcsin", 1)
    public static let ASIN3 = Function("sin⁻¹", 1)
    /** Returns the trigonometric arc-cosine of an angle. The angle is expressed in radian.*/
    public static let ACOS = Function("acos", 1)
    public static let ACOS2 = Function("arccos", 1)
    public static let ACOS3 = Function("cos⁻¹", 1)
    /** Returns the trigonometric arc-tangent of an angle. The angle is expressed in radian.*/
    public static let ATAN = Function("atan", 1)
    public static let ATAN2 = Function("arctan", 1)
    public static let ATAN3 = Function("tan⁻¹", 1)
    /** 反余切 */
    public static let ACOT = Function("acot", 1)
    public static let ACOT2 = Function("arccot", 1)
    public static let ACOT3 = Function("cot⁻¹", 1)

    /** Returns the hyperbolic sine of a number.*/
    public static let SINH = Function("sinh", 1)
    /** Returns the hyperbolic cosine of a number.*/
    public static let COSH = Function("cosh", 1)
    /** Returns the hyperbolic tangent of a number.*/
    public static let TANH = Function("tanh", 1)

    /** Returns the minimum of n numbers (n&gt;=1) */
    public static let MIN = Function("min", 1, Int.max)
    /** Returns the maximum of n numbers (n&gt;=1)   maz=max x避免当*处理 */
    public static let MAX = Function("maz", 1, Int.max)
    /** Returns the sum of n numbers (n&gt;=1) */
    public static let SUM = Function("sum", 1, Int.max)
    /** Returns the average of n numbers (n&gt;=1) */
    public static let AVERAGE = Function("avg", 1, Int.max)
    /** Returns the sum of n numbers (n&gt;=1) */
    public static let MEDIAN = Function("median", 1, Int.max)
    /** Returns the average of n numbers (n&gt;=1) */
    public static let MODE = Function("mode", 1, Int.max)
    /** 方差 */
    public static let VARIANCE = Function("variance", 1, Int.max)
    /** 标准差 */
    public static let STDDEVIATION = Function("stddeviation", 1, Int.max)
    /** Returns the natural logarithm of a number */
    public static let LN = Function("ln", 1);
    /** Returns the decimal logarithm of a number */
    public static let LOG = Function("log", 1, 2);
    
    /** Returns a pseudo random number */
    public static let RANDOM = Function("random", 0);
    /** Defines the new function (square root).*/
    public static let SQRT = Function("sqrt", 1)
    public static let CBRT = Function("cbrt", 1);
    public static let FACTORIAL_ORIGIN = Function("factorial", 1)

    /** The negate unary operator in the standard operator precedence.*/
    public static let NEGATE = Operator("-", 1, .right, 3);
    /** The negate unary operator in the Excel like operator precedence.*/
    public static let NEGATE_HIGH = Operator("-", 1, .right, 5);
    /** The substraction operator.*/
    public static let MINUS = Operator("-", 2, .left, 1);
    /** The addition operator.*/
    public static let PLUS = Operator("+", 2, .left, 1);
    /** The multiplication operator.*/
    public static let MULTIPLY = Operator("*", 2, .left, 2);
    public static let MULTIPLY2 = Operator("x", 2, .left, 2);
    /** The division operator.*/
    public static let DIVIDE = Operator("/", 2, .left, 2);
    public static let DIVIDE2 = Operator("÷", 2, .left, 2);
    /** The exponentiation operator.*/
    public static let EXPONENT = Operator("^", 2, .left, 4);
    /** The <a href="http://en.wikipedia.org/wiki/Modulo_operation">modulo operator</a>.*/
    public static let MODULO = Operator("%", 1, .left, 4);
    // 计算阶乘
    public static let FACTORIAL = Operator("!", 1, .left, 4)
    // 开方
    public static let OSQRT = Operator("√", 2, .left, 4)


    /** The standard whole set of predefined operators */
    private static let OPERATORS: [Operator] = [NEGATE, MINUS, PLUS, MULTIPLY, MULTIPLY2, DIVIDE, DIVIDE2, EXPONENT, MODULO, FACTORIAL, OSQRT]
        /** The excel like whole set of predefined operators */
    private static let OPERATORS_EXCEL: [Operator] = [NEGATE_HIGH, MINUS, PLUS, MULTIPLY, MULTIPLY2, DIVIDE, DIVIDE2, EXPONENT, MODULO, FACTORIAL, OSQRT]
        /** The whole set of predefined functions */
    private static let FUNCTIONS : [Function] = [SIN, COS, TAN, COT, ASIN, ASIN2, ASIN3, ACOS, ACOS2, ACOS3, ATAN, ATAN2, ATAN3, ACOT, ACOT2, ACOT3, SINH, COSH, TANH, MIN, MAX, SUM, AVERAGE, MEDIAN, MODE, VARIANCE, STDDEVIATION, LN, LOG, ROUND, CEIL, FLOOR, ABS, RANDOM, SQRT, CBRT, FACTORIAL_ORIGIN]
        /** The whole set of predefined constants */
    private static let CONSTANTS: [EvaluatorConstant] = [PI, PI2, E]
        
    private static var DEFAULT_PARAMETERS: Parameters?
    // 科学正则表达式
    private static let SCIENTIFIC_NOTATION_PATTERN: String = "([+-]?(?:\\d+(?:\\.\\d*)?|\\.\\d+)[eE][+-]?\\d+)$"
    
    /// Gets a copy of DecimalEvaluator standard default parameters. The returned parameters contains all the predefined operators, functions and constants. Each call to this method create a new instance of Parameters.
    /// - Returns: a Paramaters instance
    class func getDefaultParameters() -> Parameters {
        return getDefaultParameters(.STANDARD)
    }

    /// Gets a copy of DecimalEvaluator default parameters. The returned parameters contains all the predefined operators, functions and constants. Each call to this method create a new instance of Parameters.
    /// - Parameter style: The operator precedence style of teh evaluator.
    /// - Returns: a Parameters instance
    class func getDefaultParameters(_ style: Style) -> Parameters {
        let result = Parameters()
        result.addOperators(style == .STANDARD ? OPERATORS : OPERATORS_EXCEL)
        result.addFunctions(FUNCTIONS)
        result.addConstants(CONSTANTS)
        result.addFunctionBracket(BracketPair.PARENTHESES)
        result.addExpressionBracket(BracketPair.PARENTHESES)
        return result
    }

    class func getParameters() -> Parameters {
        if DEFAULT_PARAMETERS == nil {
            DEFAULT_PARAMETERS = getDefaultParameters()
        }
        return DEFAULT_PARAMETERS!
    }

    private var supportsScientificNotation: Bool = false
    // 是否支持角度制，默认弧度制
    private var supportsDegree: Bool = true
    // 是否支持百分比增量模式(5+50%=7.5)、数学模式(5+50%=5.5)
    private var supportsPercentage: Bool = false

    /// This default constructor builds an instance with all predefined operators, functions and constants.
    public convenience init() {
        self.init(Self.getParameters())
    }
    
    /// This constructor can be used to reduce the set of supported operators, functions or constants, or to localize some function or constant's names.
    /// - Parameter parameters: The parameters of the evaluator.
    public convenience init(_ parameters: Parameters) {
        self.init(parameters, true, false, false)
    }
    
    ///
    /// - Parameter supportsDegree: 是否支持角度制
    public convenience init(_ supportsDegree: Bool, _ supportsPercentage: Bool) {
        self.init(Self.getParameters(), supportsDegree, supportsPercentage, false)
    }
    
    /// This constructor can be used to reduce the set of supported operators, functions or constants, or to localize some function or constant's names.
    /// - Parameters:
    ///   - parameters: The parameters of the evaluator.
    ///   - supportsScientificNotation: supportsScientificNotation true to support scientific number notation (false is the default). Please note that supporting scientific number notation makes the evaluator twice as slow.
    public convenience init(_ parameters: Parameters, _ supportsScientificNotation: Bool) {
        self.init(parameters, true, false, supportsScientificNotation)
    }
    
    /// This constructor can be used to reduce the set of supported operators, functions or constants, or to localize some function or constant's names.
    /// - Parameters:
    ///   - parameters: The parameters of the evaluator.
    ///   - supportsDegree: 三角函数是否使用角度制
    ///   - supportsScientificNotation: true to support scientific number notation (false is the default). Please note that supporting scientific number notation makes the evaluator twice as slow.
    public init(_ parameters: Parameters, _ supportsDegree: Bool, _ supportsPercentage: Bool, _ supportsScientificNotation: Bool) {
        try! super.init(parameters: parameters)
        self.supportsDegree = supportsDegree
        self.supportsPercentage = supportsPercentage
        self.supportsScientificNotation = supportsScientificNotation
    }

    override func tokenize(_ expression: String) -> StringTokenizerIterator {
        return super.tokenize(expression)
    }

    class func isScientificNotation(_ str: String) -> Bool {
        let rules = NSPredicate(format: "SELF MATCHES %@", SCIENTIFIC_NOTATION_PATTERN)
        let isMatch: Bool = rules.evaluate(with: str)
        return isMatch
    }

    override func toValue(_ literal: String, _ evaluationContext : AnyObject?) throws -> NSDecimalNumber {
        if let _ = Double(literal) {
            return NSDecimalNumber(string: literal)
        }
        throw EvaluatorError.mesg("\(literal) is not a number")
    }
    
    /// 常量或数字
    /// - Parameters:
    ///   - constant: 常量
    ///   - evaluationContext:
    /// - Returns: 
    override func evaluate(_ constant: EvaluatorConstant, _ evaluationContext: AnyObject?) -> NSDecimalNumber {
        if DecimalEvaluator.PI == constant || DecimalEvaluator.PI2 == constant {
            return NSDecimalNumber(string: "\(Double.pi)")
        } else if DecimalEvaluator.E == constant {
            return NSDecimalNumber(string: "\(DecimalEvaluator.CONSTANT_E)")
        } else {
            return try! super.evaluate(constant, evaluationContext)!
        }
    }

    /// 操作符运算
    /// - Parameters:
    ///   - ope: 操作符
    ///   - operands:
    ///   - evaluationContext:
    /// - Returns:
    override func evaluate(_ ope: Operator, _ operands: ListIterator<NSDecimalNumber>, _ evaluationContext: AnyObject?) throws -> NSDecimalNumber {
        if DecimalEvaluator.NEGATE == ope
            || DecimalEvaluator.NEGATE_HIGH == ope {
            return operands.next().multiplying(by: NSDecimalNumber(value: -1))
        } else if DecimalEvaluator.MINUS == ope {
            let left = operands.next()
            let right = operands.next()
            if right.hasPercentage {
                let value = NSDecimalNumber(integerLiteral: 1).subtracting(right)
                return left.multiplying(by: value)
            }
            return left.subtracting(right)
        } else if DecimalEvaluator.PLUS == ope {
            let left = operands.next()
            let right = operands.next()
            if right.hasPercentage {
                let value = NSDecimalNumber(integerLiteral: 1).adding(right)
                return left.multiplying(by: value)
            }
            
            return left.adding(right)
        } else if DecimalEvaluator.MULTIPLY == ope
                    || DecimalEvaluator.MULTIPLY2 == ope {
            return operands.next().multiplying(by: operands.next())
        } else if DecimalEvaluator.DIVIDE == ope
                    || DecimalEvaluator.DIVIDE2 == ope {
            let x = operands.next()
            let y = operands.next()
            if y == 0 {
                throw EvaluatorError.mesg("Divisor cannot be 0")
            }
            return x.dividing(by: y)
        } else if DecimalEvaluator.EXPONENT == ope {
            let result = pow(operands.next().doubleValue, operands.next().doubleValue)
            return NSDecimalNumber(value: result)
        } else if DecimalEvaluator.MODULO == ope {
            let result = operands.next().dividing(by: NSDecimalNumber(value: 100))
            if supportsPercentage {
                result.hasPercentage = true
            }
            return result
        } else if DecimalEvaluator.FACTORIAL == ope {
            let result = try MathUtil.factorialV2(operands.next().intValue)
            return result
        } else if DecimalEvaluator.OSQRT == ope {
            let y = operands.next()
            let x = operands.next()
            let result = MathUtil.sqrt(x.doubleValue, y.doubleValue)
            return NSDecimalNumber(value: result)
        } else {
            return try super.evaluate(ope, operands, evaluationContext)!
        }
    }
    
    /// 函数操作
    /// - Parameters:
    ///   - function: 函数
    ///   - arguments: 参数
    ///   - evaluationContext:
    /// - Returns:
    override func evaluate(_ function: Function, _ arguments: ListIterator<NSDecimalNumber>, _ evaluationContext: AnyObject?) throws -> NSDecimalNumber {
        var result: NSDecimalNumber = NSDecimalNumber(value: 0)
        if DecimalEvaluator.ABS == function {
            result = MathUtil.absNum(arguments.next())
        } else if DecimalEvaluator.CEIL == function {
            result = NSDecimalNumber(value: ceil(arguments.next().doubleValue))
        } else if DecimalEvaluator.FLOOR == function {
            result = NSDecimalNumber(value: floor(arguments.next().doubleValue))
        } else if DecimalEvaluator.ROUND == function {
            let arg = arguments.next().doubleValue
            if arg == Double.infinity || arg == Double.nan {
                result = NSDecimalNumber(value: arg)
            } else {
                result = NSDecimalNumber(value: round(arg))
            }
        } else if DecimalEvaluator.SINH == function {
            result = NSDecimalNumber(value: sinh(toRadians(arguments.next().doubleValue)))
        } else if DecimalEvaluator.COSH == function {
            result = NSDecimalNumber(value: cosh(toRadians(arguments.next().doubleValue)))
        } else if DecimalEvaluator.TANH == function {
            result = NSDecimalNumber(value: tanh(toRadians(arguments.next().doubleValue)))
        } else if DecimalEvaluator.SIN == function {
            result = NSDecimalNumber(value: sin(toRadians(arguments.next().doubleValue)))
        } else if DecimalEvaluator.COS == function {
            result = NSDecimalNumber(value: cos(toRadians(arguments.next().doubleValue)))
        } else if DecimalEvaluator.TAN == function {
            let input = arguments.next().doubleValue
            if supportsDegree {
                if input.truncatingRemainder(dividingBy: 90) == 0 {
                    throw EvaluatorError.mesg("Calculating angles doesn't make sense")
                }
            }
            let radian = toRadians(input)
            result = NSDecimalNumber(value: tan(radian))
        } else if DecimalEvaluator.COT == function {
            let input = arguments.next().doubleValue
            if supportsDegree {
                if input.truncatingRemainder(dividingBy: 180) == 0 {
                    throw EvaluatorError.mesg("Calculating angles doesn't make sense")
                }
            }
            let radian = toRadians(input)
            result = NSDecimalNumber(value: tan(radian))
            result = NSDecimalNumber(value: 1).dividing(by: result)
        } else if DecimalEvaluator.ASIN == function
                   || DecimalEvaluator.ASIN2 == function
                   || DecimalEvaluator.ASIN3 == function {
            let arg = arguments.next().doubleValue
            result = NSDecimalNumber(value: toTrigonometricValue(asin(arg)))
        } else if DecimalEvaluator.ACOS == function
                   || DecimalEvaluator.ACOS2 == function
                   || DecimalEvaluator.ACOS3 == function {
            result = NSDecimalNumber(value: toTrigonometricValue(acos(arguments.next().doubleValue)))
        } else if DecimalEvaluator.ATAN == function
                   || DecimalEvaluator.ATAN2 == function
                   || DecimalEvaluator.ATAN3 == function {
            result = NSDecimalNumber(value: toTrigonometricValue(atan(arguments.next().doubleValue)))
        } else if DecimalEvaluator.ACOT == function
                    || DecimalEvaluator.ACOT2 == function
                    || DecimalEvaluator.ACOT3 == function {
            let value = arguments.next().doubleValue
            if value == 0 {
                throw EvaluatorError.mesg("Solving numbers is meaningless")
            }
            result = NSDecimalNumber(value: toTrigonometricValue(atan(1 / value)))
         } else if DecimalEvaluator.MIN == function {
            var resultValue = arguments.next().doubleValue
            while (arguments.hasNext()) {
                resultValue = min(resultValue, arguments.next().doubleValue)
            }
            result = NSDecimalNumber(value: resultValue)
        } else if DecimalEvaluator.MAX == function {
            var resultValue = arguments.next().doubleValue
            while (arguments.hasNext()) {
                resultValue = max(resultValue, arguments.next().doubleValue)
            }
            result = NSDecimalNumber(value: resultValue)
        } else if DecimalEvaluator.SUM == function {
            var resultValue = NSDecimalNumber(value: 0)
            while (arguments.hasNext()) {
                resultValue = resultValue.adding(arguments.next())
            }
            result = resultValue
        } else if DecimalEvaluator.AVERAGE == function {
            var nb: Int = 0
            while (arguments.hasNext()) {
                result = result.adding(arguments.next())
                nb += 1
            }
            // Remember that method is called only if the number of parameters match with the function
            // definition => nb will never remain 0 (There's a junit test that fails if it would not be the case).
            result = result.dividing(by: NSDecimalNumber(value: nb))
        } else if DecimalEvaluator.VARIANCE == function {
            var values = [Double]()
            while (arguments.hasNext()) {
                values.append(arguments.next().doubleValue)
            }
            result = NSDecimalNumber(value: MathUtil.variance(values))
        } else if DecimalEvaluator.STDDEVIATION == function {
            var values = [Double]()
            while (arguments.hasNext()) {
                values.append(arguments.next().doubleValue)
            }
            result = NSDecimalNumber(value: MathUtil.standardDeviation(values))
        } else if DecimalEvaluator.MEDIAN == function {
            var values = [Double]()
            while (arguments.hasNext()) {
                values.append(arguments.next().doubleValue)
            }
            result = NSDecimalNumber(value: MathUtil.median(values))
        } else if DecimalEvaluator.MODE == function {
            var values = [Double]()
            while (arguments.hasNext()) {
                values.append(arguments.next().doubleValue)
            }
            result = NSDecimalNumber(value: MathUtil.mode(values))
        } else if DecimalEvaluator.LN == function {
            result = NSDecimalNumber(value: log(arguments.next().doubleValue))
        } else if DecimalEvaluator.LOG == function {
            let x = arguments.next().doubleValue
            if (arguments.hasNext()) {
                let y = arguments.next().doubleValue
                result = NSDecimalNumber(value: MathUtil.log(y, x))
            } else {
                result = NSDecimalNumber(value: log10(x))
            }
        } else if DecimalEvaluator.RANDOM == function {
            result =  NSDecimalNumber(value: MathUtil.random())
        } else if DecimalEvaluator.FACTORIAL_ORIGIN == function {
            result = try MathUtil.factorialV2(arguments.next().intValue)
        } else if DecimalEvaluator.SQRT == function {
            result =  NSDecimalNumber(value: sqrt(arguments.next().doubleValue))
        } else if DecimalEvaluator.CBRT == function {
            result = NSDecimalNumber(value: cbrt(arguments.next().doubleValue))
        } else {
            result = try super.evaluate(function, arguments, evaluationContext)!
        }
        try? errIfNaN(result.doubleValue, function)
        return result
    }

    
    /// 得到反三角函数结果
    /// - Parameter argument: 弧度
    /// - Returns:
    func toTrigonometricValue(_ argument : Double) -> Double {
        if supportsDegree {
            return MathUtil.toDegrees(argument)
        }
        
        return argument
    }
    
    /**
     * 计算弧度制，输入
     * @param argument 角度、弧度
     * @return
     */
    func toRadians(_ argument : Double) -> Double {
        if !supportsDegree {
            return argument
        }
        
        return MathUtil.toRadians(argument)
    }

    func errIfNaN(_ result: Double, _ function: Function) throws {
        if (result.isNaN) {
            throw EvaluatorError.mesg("Invalid argument passed to \(function.name)")
        }
    }
    
}
