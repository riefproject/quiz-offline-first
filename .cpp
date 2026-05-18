#include <bits/stdc++.h>
using namespace std;

void solve(){
    int n; cin >> n;
    vector<pair<int, int>> a(n);
    vector<int> b(n);
    for(int i = 0; i < n; ++i){
        cin >> b[i];
        a[i].second = i;
    }
    for(int i = 0, id = 0; i < n; ++i, id = (id + 5) % n)
        a[(id + 5) % n].first = b[(id + 1) % n] - b[id] + a[id].first;
        
    sort(a.begin(), a.end());
    for(int i = 0; i < 5; ++i)
        cout << a[i].second << ' ';
}

int main(){
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int t = 1;
    // cin >> t;

    while(t--)
        solve();
    
    return 0;
}