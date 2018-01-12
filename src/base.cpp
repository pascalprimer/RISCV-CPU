#include <bits/stdc++.h>
using namespace std;

string bit[1111];

int main() {
	bit['0'] = "0000";
	bit['1'] = "0001";
	bit['2'] = "0010";
	bit['3'] = "0011";
	bit['4'] = "0100";
	bit['5'] = "0101";
	bit['6'] = "0110";
	bit['7'] = "0111";
	bit['8'] = "1000";
	bit['9'] = "1001";
	bit['a'] = "1010";
	bit['b'] = "1011";
	bit['c'] = "1100";
	bit['d'] = "1101";
	bit['e'] = "1110";
	bit['f'] = "1111";

	string str;
	while (cin >> str) {
		for (int i = 0; i < 4; ++i) {
			int id = (3 - i) * 2;
			cout << bit[str[id]];
			cout << bit[str[id + 1]];
		}
		cout << endl;
		/*str = temp;
		string ans;
		for (int i = 0; i < str.length(); i += 4) {
			int x = (str[i] - '0') << 3 |
					(str[i + 1] - '0') << 2 |
					(str[i + 2] - '0') << 1 |
					(str[i + 3] - '0');
			char c = x < 10 ? x + '0' : 'a' + x - 10;
			ans = ans + c;
		}
		swap(ans[0], ans[6]);
		swap(ans[1], ans[7]);
		swap(ans[2], ans[4]);
		swap(ans[3], ans[5]);
		cout << ans << endl;*/
	}
}
