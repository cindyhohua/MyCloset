func sum(toNumber: Int) -> Int {
    var x = 0
    for i in 1...toNumber {
        x += i
    }
    return x
}

func sum2(toNumber: Int) -> Int {
    return (1+toNumber)*toNumber/2
}

sum(toNumber: 10)
sum2(toNumber: 10)


let x = [7,36,13,47,28,50,1]
func searchPosition(number: Int) -> (Bool, Int) {
    for i in 0..<x.count {
        if x[i] == number {
            return (true, i)
        }
    }
    return (false, -1)
}

searchPosition(number: 47)


//let y = [1,7,13,28,36,47,50]
//y.count / 2
//func searchPosition2(number: Int) -> (Bool, Int) {
//    var k = y.count/2
//    while y[k] != number {
//        if y[k] > number {
//            k = (k + y.count/2)/2
//        } else if y[k] < number {
//            k = (k + y.count/2)/2
//        } else if y[k] == number {
//            return (true, k)
//        }
//    }
//    return (false, -1)
//}

func sort(array: [Int]) -> [Int] {
    var xx = array
    var y: [Int] = []
    for _ in 0..<array.count-1{
        y.append(xx.min()!)
        xx.remove(at: xx.firstIndex(of: xx.min()!)!)
    }
    return y
}

sort(array: x)
