import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Button, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  faxes: FaxInfo[];
  max_connections: number;
  notification: BooleanLike;
};

type FaxInfo = {
  fax_id: string;
  fax_name: string;
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
                  <Table.Row key={fax.fax_id}>
                    <Table.Cell collapsing>
                      {faxes.indexOf(fax) + 1}. {fax.fax_name}
                    </Table.Cell>
                    <Table.Cell />
                    <Table.Cell>{fax.fax_id}</Table.Cell>

                    <Table.Cell collapsing>
                      <Button
                        icon="link-slash"
                        tooltip="Disconnect"
                        onClick={() => act('disconnect', { id: fax.fax_id })}
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
          </Table>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
