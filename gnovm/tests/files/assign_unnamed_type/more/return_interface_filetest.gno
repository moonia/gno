package main

type nat []int

func x() any {
	a := nat{0}
	return a
}

func main() {
	var a nat

	a = x()

	println(a)
}

// Error:
// main/files/assign_unnamed_type/more/return_interface_filetest.gno:13:2: cannot use interface {} as []int
