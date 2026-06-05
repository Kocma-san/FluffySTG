import { useState } from 'react';
import { Box, Button, Icon, Section, Stack, Tabs } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  numeric_input: string;
  avalible_phones: PhoneInfo[];
};

type PhoneInfo = {
  phone_id: string;
  phone_name: string;
};

export const Telephone = () => {
  const { data, act } = useBackend<Data>();
  const { numeric_input, avalible_phones } = data;

  const categories = ['weh', 'blep'];

  const [selectedPhone, setSelectedPhone] = useState('');
  const [currentCategory, setCategory] = useState(categories[0]);

  return (
    <Window width={520} height={420} theme="retro">
      <Window.Content>
        <Stack>
          <Stack.Item>
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
                              (_, a, b, c) =>
                                [a, b, c].filter(Boolean).join('-'),
                            )
                          : null}
                      </Box>
                    </Stack.Item>
                    <Stack.Item align="center" mt={2}>
                      <PhoneKeypad />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                {/* <Stack.Item grow /> */}
              </Stack>
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              {categories.map((val) => (
                <Tabs.Tab
                  selected={val === currentCategory}
                  onClick={() => setCategory(val)}
                  key={val}
                >
                  {val}
                </Tabs.Tab>
              ))}
            </Tabs>
            <Section>
              <Box
                style={{
                  backgroundColor: 'hsla(48, 100%, 99%, 1.00)',
                  minHeight: '250px',
                  minWidth: '250px',
                  border: '2px solid black',
                  backgroundImage:
                    'repeating-linear-gradient(to bottom, rgba(0, 0, 0, 0.06) 0px, rgba(0, 0, 0, 0.06) 1px, transparent 1px, transparent 24px)',
                  fontSize: '16px',
                  margin: 2,
                  padding: '5px 5px',
                }}
              >
                <Tabs vertical>
                  {avalible_phones.map((val) => {
                    return (
                      <Tabs.Tab
                        // selected={selectedPhone === val.phone_id}
                        onClick={() => {
                          if (selectedPhone === val.phone_id) {
                            act('call', { phone_id: selectedPhone });
                          } else {
                            setSelectedPhone(val.phone_id);
                          }
                        }}
                        key={val.phone_id}
                        fontSize="1rem"
                      >
                        <Stack color="black">
                          <Stack.Item grow>{val.phone_name}</Stack.Item>
                          <Stack.Item>
                            {val.phone_id.replace(
                              /(\d{2})(\d{1,3})?(\d{1,3})?/,
                              (_, a, b, c) =>
                                [a, b, c].filter(Boolean).join('-'),
                            )}
                          </Stack.Item>
                        </Stack>
                      </Tabs.Tab>
                    );
                  })}
                </Tabs>
              </Box>
            </Section>
            {/* {!!selectedPhone && (
              <Box>
                <Button
                  color="good"
                  fluid
                  textAlign="center"
                  onClick={() => act('call', { phone_id: selectedPhone })}
                >
                  Dial
                </Button>
              </Box>
            )} */}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const KEYPAD = [
  ['1', '4', '7', 'phone'],
  ['2', '5', '8', '0'],
  ['3', '6', '9', 'C'],
] as const;

function PhoneKeypad() {
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
                  `Telephone__Button`,
                  `Telephone__Button--keypad`,
                  `Telephone__Button--${key}`,
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
