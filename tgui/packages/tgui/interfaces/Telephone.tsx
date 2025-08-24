import { Box, Button, Icon, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  numeric_input: string;
};

export const Telephone = (props) => {
  const { act, data } = useBackend<Data>();
  const { numeric_input } = data;
  return (
    <Window width={325} height={420} theme="retro">
      <Window.Content>
        <Box>
          <Stack mt={2}>
            <Stack.Item mx={4}>
              <Stack vertical>
                <Stack.Item>
                  <Box height={4} className="Telephone__displayBox">
                    {numeric_input
                      ? '+' +
                        numeric_input.replace(
                          /(\d{2})(\d{1,3})?(\d{1,3})?/,
                          (_, a, b, c) => [a, b, c].filter(Boolean).join('-'),
                        )
                      : null}
                  </Box>
                </Stack.Item>
                <Stack.Item align="center" mt={2}>
                  <PhoneKeypad />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow />
          </Stack>
        </Box>
      </Window.Content>
    </Window>
  );
};

const KEYPAD = [
  ['1', '4', '7', 'phone'],
  ['2', '5', '8', '0'],
  ['3', '6', '9', 'C'],
] as const;

export function PhoneKeypad(props) {
  const { act } = useBackend();

  return (
    <Box width="185px">
      <Stack>
        {KEYPAD.map((keyColumn) => (
          <Stack.Item key={keyColumn[0]}>
            {keyColumn.map((key) => (
              <Button
                fluid
                bold
                key={key}
                mb={1}
                textAlign="center"
                fontSize="40px"
                lineHeight={1.25}
                width="55px"
                className={classes([
                  'Telephone__Button',
                  'Telephone__Button--keypad',
                  'Telephone__Button--' + key,
                ])}
                onClick={() => {
                  act('keypad', { digit: key });
                }}
              >
                {key !== 'phone' ? (
                  key
                ) : (
                  <Icon
                    name={key}
                    size={0.8}
                    align="center"
                    verticalAlign="center"
                  />
                )}
              </Button>
            ))}
          </Stack.Item>
        ))}
      </Stack>
    </Box>
  );
}
