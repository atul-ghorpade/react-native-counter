import React, { useRef, useCallback, useState } from 'react';
import { View, StyleSheet } from 'react-native';
import NativeCounterView, { Commands } from './NativeCounterView';
import type { NativeCounterViewProps } from './NativeCounterView';

export interface CounterViewProps {
  onCountChange?: (count: number) => void;
  style?: any;
}

export const CounterView: React.FC<CounterViewProps> = ({ onCountChange, style }) => {
  const ref = useRef(null);
  const [count, setCount] = useState(0);

  const handleCountChange = useCallback(
    (event: any) => {
      const newCount = event.nativeEvent.count;
      setCount(newCount);
      onCountChange?.(newCount);
    },
    [onCountChange]
  );

  return (
    <View style={[styles.container, style]}>
      <NativeCounterView
        ref={ref}
        style={styles.nativeView}
        count={count}
        onCountChange={handleCountChange}
      />
    </View>
  );
};

export const useCounter = () => {
  const ref = useRef(null);

  const increment = useCallback(() => {
    if (ref.current) {
      Commands.increment(ref.current);
    }
  }, []);

  const decrement = useCallback(() => {
    if (ref.current) {
      Commands.decrement(ref.current);
    }
  }, []);

  return { ref, increment, decrement };
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  nativeView: {
    flex: 1,
  },
});

