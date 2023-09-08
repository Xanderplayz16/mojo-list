
from memory.unsafe import Pointer

struct List[T: AnyType]:
    var storage: Pointer[T]
    var count: Int
    var capacity: Int
    
    fn __init__(inout self):
        self.count = 0
        self.capacity = 10
        self.storage = Pointer[T].alloc(10)
    
    fn __init__[*Ts: AnyType](inout self, owned literal: ListLiteral[Ts]):
        let req_len = len(literal)
        if req_len == 0:
            self = Self()
        else:
            self.count = req_len
            self.capacity = req_len
            self.storage = Pointer[T].alloc(req_len)
            let src = Pointer.address_of(literal).bitcast[T]()
            for i in range(req_len):
                self.storage.store(i, src.load(i))
              
    fn __getitem__(self, i: Int) -> T:
        return self.storage.load(i)
    
    fn __setitem__(inout self, i: Int, value: T):
        self.storage.store(i, value)
    
    fn __len__(self) -> Int:
        return self.count
    
    fn __iter__(self) -> ListIterator[T]:
        return ListIterator[T](self.storage, self.count)
    
    fn __moveinit__(inout self, owned previous: Self):
        self.count = previous.count
        self.capacity = previous.capacity
        self.storage = previous.storage
    
    # this is currently impossible to safely automate
    # while maintaining iterator support
    # at least I could not find a way
    fn __del__(owned self): pass
        # self.storage.free()
    # this is necessary
    fn free(self):
        self.storage.free()
    
    fn resize(inout self, by: Int):
        let new_capacity = self.capacity + by
        let new = Pointer[T].alloc(new_capacity)
        for i in range(self.count):
            new.store(i, self.storage.load(i))
        self.storage.free()
        self.storage = new
        self.capacity = new_capacity
    
    fn append(inout self, value: T):
        if self.count >= self.capacity:
            self.resize(self.capacity * 2)
        self[self.count] = value
        self.count += 1
    
    fn append(inout self, list: List[T]):
        for item in list: self.append(item)
    
    fn drop_last(inout self):
        self.count -= 1
    
    fn reserve_capacity(inout self, capacity: Int):
        if self.capacity < capacity:
            self.resize(capacity)
    
    fn map[A: AnyType](self, body: fn(T) capturing -> A) -> List[A]:
        var buf = List[A]()
        buf.reserve_capacity(self.count)
        for item in self: buf.append(body(item))
        return buf^
    
    fn map[A: AnyType](self, body: fn(T) -> A) -> List[A]:
        var buf = List[A]()
        buf.reserve_capacity(self.count)
        for item in self: buf.append(body(item))
        return buf^
    
    fn filter(self, body: fn(T) capturing -> Bool) -> List[T]:
        var buf = List[T]()
        for item in self:
            if body(item): buf.append(item)
        return buf^
    
    fn filter(self, body: fn(T) -> Bool) -> List[T]:
        var buf = List[T]()
        for item in self:
            if body(item): buf.append(item)
        return buf^
    
    fn fold[A: AnyType](self, owned into: A, body: fn(A, T) capturing -> A) -> A:
        var acc = into
        for item in self:
            acc = body(acc, item)
        return acc
    
    fn fold[A: AnyType](self, owned into: A, body: fn(A, T) -> A) -> A:
        var acc = into
        for item in self:
            acc = body(acc, item)
        return acc

struct ListIterator[T: AnyType]:
    var offset: Int
    var max: Int
    var storage: Pointer[T]
    
    fn __init__(inout self, storage: Pointer[T], max: Int):
        self.offset = 0
        self.max = max
        self.storage = storage
    
    fn __len__(self) -> Int:
        return self.max - self.offset
    
    fn __next__(inout self) -> T:
        let ret = self.storage.load(self.offset)
        self.offset += 1
        return ret
    