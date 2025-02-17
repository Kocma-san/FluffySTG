import {
  Button,
  Dimmer,
  Icon,
  LabeledList,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  faxes: FaxInfo[];
  max_connections: number;
  notification: BooleanLike;
};

type FaxInfo = {
  fax_id: string;
  fax_name: string;
  muted: BooleanLike;
};

export const NtosFaxManager = (props) => {
  const { act, data } = useBackend<Data>();
  const { faxes, notification } = data;

  return (
    <NtosWindow width={400} height={400}>
      <NtosWindow.Content>
        <Section
          title={'Connected Faxes ' + faxes.length + '/' + data.max_connections}
          buttons={
            <>
              <Button
                icon={notification ? 'bell-slash' : 'bell'}
                iconColor={'white'}
                tooltip={
                  notification
                    ? 'Disable notifications'
                    : 'Enable notifications'
                }
                color={notification ? null : 'red'}
                onClick={() => act('disable_all_notification')}
              />
              <Button
                icon={'right-to-bracket'}
                tooltip={'Scan for faxes'}
                onClick={() => {
                  act('scan_for_faxes');
                }}
              />
            </>
          }
        >
          <Table>
            {faxes.length === 0
              ? 'No connections'
              : faxes.map((fax: FaxInfo) => (
                  <FaxInfoSection key={fax.fax_id} fax={fax} />
                ))}
          </Table>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const FaxInfoSection = (props) => {
  const { fax } = props;
  const { act, data } = useBackend();
  const color = 'rgba(74, 59, 140, 1)';

  return (
    <Section
      title={fax.fax_name}
      style={{
        border: `4px solid ${color}`,
      }}
    >
      <Stack>
        <Stack.Item grow={1} basis={0}>
          <LabeledList>
            <LabeledList.Item label="Name">{fax.fax_name}</LabeledList.Item>
            <LabeledList.Item label="ID">{fax.fax_id}</LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            icon="link-slash"
            tooltip="Disconnect"
            onClick={() => act('disconnect', { id: fax.fax_id })}
          />
          <Button
            icon={fax.muted ? 'bell' : 'bell-slash'}
            iconColor={'white'}
            tooltip={
              fax.muted ? 'Enable notifications' : 'Disable notifications'
            }
            color={fax.muted ? 'red' : null}
            onClick={() => act('mute_fax', { id: fax.fax_id })}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// Однажды я доделаю...

const FaxDimmer = (props: number) => {
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        {props === 0 && <DimmerContentLoading />}
        {props === 1 && <DimmerContentSuccess />}
        {props === 2 && <DimmerContentAlreadyConnected />}
        {props === 3 && <DimmerContentManyFaxes />}
        {props === 4 && <DimmerContentNoFound />}
      </Stack>
    </Dimmer>
  );
};

const DimmerContentLoading = (props) => {
  return (
    <>
      <Stack.Item>
        <Icon color="white" name="rotate" spin size={4} />
      </Stack.Item>
      <Stack.Item>Connecting...</Stack.Item>
    </>
  );
};

const DimmerContentSuccess = (props) => {
  return (
    <>
      <Stack.Item>
        <Icon color="white" name="link" size={4} />
      </Stack.Item>
      <Stack.Item>Successfully connected!</Stack.Item>
    </>
  );
};

const DimmerContentNoFound = (props) => {
  return (
    <>
      <Stack.Item>
        <Icon color="white" name="triangle-exclamation" size={4} />
      </Stack.Item>
      <Stack.Item>Fax not found!</Stack.Item>
    </>
  );
};

const DimmerContentManyFaxes = (props) => {
  return (
    <>
      <Stack.Item>
        <Icon color="white" name="triangle-exclamation" size={4} />
      </Stack.Item>
      <Stack.Item>Too many faxes connected!</Stack.Item>
    </>
  );
};

const DimmerContentAlreadyConnected = (props) => {
  return (
    <>
      <Stack.Item>
        <Icon color="white" name="triangle-exclamation" size={4} />
      </Stack.Item>
      <Stack.Item>This fax is already connected!</Stack.Item>
    </>
  );
};
