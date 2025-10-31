import type { ViewProps } from 'react-native';
import type { HostComponent } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { Int32, DirectEventHandler } from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';

export type OnCountChangeEvent = Readonly<{
  count: Int32;
}>;

export interface NativeCounterViewProps extends ViewProps {
  count?: Int32;
  onCountChange?: DirectEventHandler<OnCountChangeEvent>;
}

export interface NativeCommands {
  increment: (viewRef: React.ElementRef<HostComponent<NativeCounterViewProps>>) => void;
  decrement: (viewRef: React.ElementRef<HostComponent<NativeCounterViewProps>>) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['increment', 'decrement'],
});

export default codegenNativeComponent<NativeCounterViewProps>('CounterView');

