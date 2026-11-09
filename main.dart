import 'dart:collection';

class Solution {
  List<int> busiestServers(int k, List<int> arrival, List<int> load) {
    final n = arrival.length;
    final count = List<int>.filled(k, 0);
    
    // Min-heap of busy servers: [freeTime, serverId]
    final busy = PriorityQueue<List<int>>((a, b) {
      if (a[0] != b[0]) return a[0].compareTo(b[0]);
      return a[1].compareTo(b[1]);
    });
    
    // Sorted set of free server IDs
    final free = SplayTreeSet<int>();
    for (int i = 0; i < k; i++) free.add(i);
    
    for (int i = 0; i < n; i++) {
      final time = arrival[i];
      final duration = load[i];
      
      // Free servers that finished by current time
      while (busy.isNotEmpty && busy.first[0] <= time) {
        free.add(busy.removeFirst()[1]);
      }
      
      if (free.isEmpty) continue; // drop request
      
      // Prefer server i % k, else next available
      int target = i % k;
      int server;
      if (free.contains(target)) {
        server = target;
      } else {
        // Find smallest >= target, else wrap to smallest
        final higher = free.firstWhere((s) => s >= target, orElse: () => -1);
        server = higher != -1 ? higher : free.first;
      }
      
      free.remove(server);
      busy.add([time + duration, server]);
      count[server]++;
    }
    
    final maxCount = count.reduce((a, b) => a > b ? a : b);
    final result = <int>[];
    for (int i = 0; i < k; i++) {
      if (count[i] == maxCount) result.add(i);
    }
    return result;
  }
}

// PriorityQueue helper (add if not using package:collection)
class PriorityQueue<T> {
  final List<T> _heap = [];
  final int Function(T, T) _compare;

  PriorityQueue(this._compare);

  bool get isEmpty => _heap.isEmpty;
  bool get isNotEmpty => _heap.isNotEmpty;
  T get first => _heap.first;

  void add(T value) {
    _heap.add(value);
    _bubbleUp(_heap.length - 1);
  }

  T removeFirst() {
    final result = _heap.first;
    final last = _heap.removeLast();
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _bubbleDown(0);
    }
    return result;
  }

  void _bubbleUp(int i) {
    while (i > 0) {
      final parent = (i - 1) ~/ 2;
      if (_compare(_heap[i], _heap[parent]) >= 0) break;
      _swap(i, parent);
      i = parent;
    }
  }

  void _bubbleDown(int i) {
    while (true) {
      int smallest = i;
      final left = 2 * i + 1;
      final right = 2 * i + 2;
      if (left < _heap.length && _compare(_heap[left], _heap[smallest]) < 0) {
        smallest = left;
      }
      if (right < _heap.length && _compare(_heap[right], _heap[smallest]) < 0) {
        smallest = right;
      }
      if (smallest == i) break;
      _swap(i, smallest);
      i = smallest;
    }
  }

  void _swap(int i, int j) {
    final tmp = _heap[i];
    _heap[i] = _heap[j];
    _heap[j] = tmp;
  }
}
