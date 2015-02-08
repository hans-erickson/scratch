#include <iostream>
#include <iomanip>

template<int X, int Power>
struct power
{
	const static int value = X * power<X, Power - 1>::value;
};

template<int X>
struct power<X, 1>
{
	const static int value = X;
};

template<int Numerator, int Denominator>
struct divide
{
	const static int value = Numerator / Denominator;
};

template<int Numerator>
struct divide<Numerator, 0>
{
	const static int value = 0;
};

template<int Numerator, int Denominator, int Power = 1, int Sign = 1, bool Done = false>
struct arctan
{
	const static int one = (1<<30);
	const static int term = divide<power<Numerator, Power>::value * one, power<Denominator, Power>::value * Power>::value * Sign;
	const static int value = term + arctan<Numerator, Denominator, Power + 2, -Sign, (term == 0)>::value;
};

template<int Numerator, int Denominator, int Power, int Sign>
struct arctan<Numerator, Denominator, Power, Sign, true>
{
	const static int value = 0;
};

const double pi = (double)(arctan<1, 5>::value * 4 - arctan<1, 239>::value) / (double)(1<<30) * 4;
//
// Machin's formula
// arctan(x) = x - x^3/3 + x^5/5 - x^7/7 + ...
// pi/4 = 4 arctan(1/5) - arctan(1/239)
//


int main(int argc, char** argv)
{
	std::cout << std::setprecision(12) << pi << std::endl;
}

