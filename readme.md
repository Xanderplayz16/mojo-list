### A basic resizable List implementation for Mojo
Supporting `for .. in` iteration and many convenience methods such as `map`, `append`, `insert`, `remove`, `reverse`, `reversed`, `filter`, `fold`, `zip` etc.

It's still work in progress so there might be some issues, some seem to crash the compiler.

examples:
```py

from list import List

fn test_append():
    let test = List[Int]([2, 2, 2])
    var list = List[Int]([1, 2, 3, 4])
    
    list.append(5)
    list.append(test)
    
    for item in list: print(item)
    # outputs 1 2 3 4 5 2 2 2

fn test_map():
    fn double(num: Int) -> Int: return num * num
    
    let list = List[Int]([2, 2, 2])
    let doubled = list.map[Int](double)
    
    for item in list: print(item)
    for item in doubled: print(item)
    # outputs 2 2 2 and 4 4 4

fn test_fold():
    fn sum(acc: Int, val: Int) -> Int: return acc + val
    
    let list = List[Int]([1, 2, 3])
    let folded = list.fold[Int](0, sum)
    
    for item in list: print(item)
    print(folded)
    # outputs 1 2 3 and 6

fn test_filter():
    fn greater(num: Int) -> Bool: return num > 2
    
    let list = List[Int]([1, 2, 3, 4])
    let filtered = list.filter(greater)
    
    for item in list: print(item)
    for item in filtered: print(item)
    # outputs 1 2 3 4 and 3 4
```
