a = [1, 2, 3]
b = a
s = " this is a string "
len(s) #number of characters in the string -> spaces count as characters 

s.replace(" ","-") # substitute spaces " " with dashes
s.find("s") #finds the first occurrence of "s" in the string 
s.count("s") #counts the number of occurrences of "s" in the string
t = s.split() #split the string using spaces and make a list 
t
t = s.split(" is ") # split the string using " is " and make a list out of it
t
t = s.strip() # remove trailing spaces
t
s.upper()
s.upper().strip() #can perfrom sequential operations on strings 
'W0rD'.lower() #can perform operations directly on a literal string
?s.upper
help()
for i in range(x):
    if i > 3: #4 spaces or 2 tabs in this case
        print(i)

for i in range(10):
    print(i)      
a = range(10) 
a
for i in range(1, 6):
    print(i)
for i in range(2, 10, 2): # skip odd numbers
    print(i)
my_iterable = [1, 2, 3]
type(my_iterable)
my_iterable = iter(my_iterable)
type(my_iterable)
next(my_iterable)
next(my_iterable)
next(my_iterable)
next(my_iterable)
