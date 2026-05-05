import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:rubik_app/core/app_colors.dart';
import 'package:rubik_app/cube/cube_move.dart';
import 'package:rubik_app/cube/cubie.dart';
import 'package:rubik_app/cube/cube_state.dart';

void main() {
  group('CubeMove Tests', () {
    test('Equality and HashCode', () {
      final move1 = CubeMove(0, 1, 1);
      final move2 = CubeMove(0, 1, 1);
      final move3 = CubeMove(0, -1, 1);

      expect(move1, equals(move2));
      expect(move1.hashCode, equals(move2.hashCode));
      expect(move1, isNot(equals(move3)));
    });

    test('Reverse generates correct move', () {
      final move = CubeMove(1, -1, 1);
      final reversed = move.reverse;

      expect(reversed.axis, equals(1));
      expect(reversed.layer, equals(-1));
      expect(reversed.dir, equals(-1));
      expect(reversed.reverse, equals(move));
    });

    test('Naming logic is correct for all primary moves', () {
      expect(CubeMove(1, -1, 1).name, 'U');
      expect(CubeMove(1, -1, -1).name, "U'");
      expect(CubeMove(1, 1, 1).name, 'D');
      expect(CubeMove(1, 1, -1).name, "D'");

      expect(CubeMove(0, -1, 1).name, 'L');
      expect(CubeMove(0, -1, -1).name, "L'");
      expect(CubeMove(0, 1, 1).name, 'R');
      expect(CubeMove(0, 1, -1).name, "R'");

      expect(CubeMove(2, 1, 1).name, 'F');
      expect(CubeMove(2, 1, -1).name, "F'");
      expect(CubeMove(2, -1, 1).name, 'B');
      expect(CubeMove(2, -1, -1).name, "B'");
    });
  });

  group('Cubie Tests', () {
    test('Clone creates exact copy but different reference', () {
      final cubie = Cubie(
        id: 1,
        x: 1.0,
        y: -1.0,
        z: 0.0,
        upColor: AppColors.cubeUp,
        rightColor: AppColors.cubeRight,
      );

      final cloned = cubie.clone();

      expect(cloned.id, equals(cubie.id));
      expect(cloned.x, equals(cubie.x));
      expect(cloned.y, equals(cubie.y));
      expect(cloned.z, equals(cubie.z));
      expect(cloned.upColor, equals(cubie.upColor));
      expect(cloned.rightColor, equals(cubie.rightColor));
      
      // Modify original, cloned should remain unchanged
      cubie.x = 2.0;
      expect(cloned.x, equals(1.0));
    });
  });

  group('CubeState Tests', () {
    test('Initialization sets up 27 cubies correctly and is solved', () {
      final state = CubeState();
      
      expect(state.cubies.length, equals(27));
      expect(state.isSolved(), isTrue);

      // Verify specific cubie count for outer layers
      final rightFace = state.cubies.where((c) => c.x.round() == 1).toList();
      expect(rightFace.length, equals(9));
      expect(rightFace.every((c) => c.rightColor == AppColors.cubeRight), isTrue);
    });

    test('Single Axis Rotation changes state and makes it unsolved', () {
      final state = CubeState();
      
      // Rotate R (axis 0, layer 1, dir 1)
      state.rotateSlice(0, 1, 1);

      expect(state.isSolved(), isFalse);

      // Verify cubies on x=-1 and x=0 are unchanged
      final leftFace = state.cubies.where((c) => c.x.round() == -1).toList();
      expect(leftFace.every((c) => c.leftColor == AppColors.cubeLeft), isTrue);

      // Reversing the move should solve it
      state.rotateSlice(0, 1, -1);
      expect(state.isSolved(), isTrue);
    });

    test('Complex Algorithm (Sexy Move) solves after 6 repetitions', () {
      final state = CubeState();
      
      // Sexy Move is R U R' U'
      final r = CubeMove(0, 1, 1);
      final u = CubeMove(1, -1, 1);
      final rPrime = r.reverse;
      final uPrime = u.reverse;

      final algo = [r, u, rPrime, uPrime];

      for (int i = 1; i <= 6; i++) {
        for (var move in algo) {
          state.rotateSlice(move.axis, move.layer, move.dir);
        }
        
        if (i < 6) {
          expect(state.isSolved(), isFalse, reason: 'Failed on iteration $i');
        } else {
          expect(state.isSolved(), isTrue, reason: 'Failed to solve after 6 iterations');
        }
      }
    });

    test('Floating-point stability after many rotations', () {
      final state = CubeState();
      final random = Random(42); // Seeded for determinism
      final history = <CubeMove>[];

      // Perform 500 random rotations
      for (int i = 0; i < 500; i++) {
        final axis = random.nextInt(3);
        final layer = random.nextBool() ? 1 : -1;
        final dir = random.nextBool() ? 1 : -1;
        
        final move = CubeMove(axis, layer, dir);
        state.rotateSlice(move.axis, move.layer, move.dir);
        history.add(move);
      }

      expect(state.isSolved(), isFalse);

      // Reverse all rotations
      for (var move in history.reversed) {
        final rev = move.reverse;
        state.rotateSlice(rev.axis, rev.layer, rev.dir);
      }

      // Should be solved and robust against float errors due to round()
      expect(state.isSolved(), isTrue);
    });
  });
}
