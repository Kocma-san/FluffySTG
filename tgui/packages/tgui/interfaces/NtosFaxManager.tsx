import {
  Button,
  Dimmer,
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
                icon={notification ? 'bell' : 'bell-slash'}
                iconColor={'white'}
                tooltip={
                  notification
                    ? 'Disable notifications'
                    : 'Enable notifications'
                }
                color={notification ? null : 'red'}
                onClick={() => act('disable_notification')}
              />
              <Button
                icon={'right-to-bracket'}
                tooltip={'Scan for faxes'}
                onClick={() => act('scan_for_faxes')}
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
        {/* {!notification && <FaxDimmer faxes={faxes} />} */}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type FaxDimmerProps = {
  faxes: FaxInfo[];
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
            tooltip={(fax.muted ? 'Disable' : 'Enable') + ' notifications'}
            color={fax.muted ? null : 'red'}
            onClick={() => act('mute_fax', { id: fax.fax_id })}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const FaxDimmer = (props: FaxDimmerProps) => {
  const faxes = props.faxes;
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item>
          <Table />
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};
