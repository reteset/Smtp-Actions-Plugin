        ��  ��                  `  H   T E X T F I L E   I D R _ A C T I O N S X M L       0        <ActionTemplates>
	<Action>
		<Name>SMTP.SendMail</Name>
		<Description>Sends a mail through your mail server.</Description>
		<ReturnValueType>string</ReturnValueType>
		<Arguments>
			<Arg>
				<Name>MailProperties</Name>
				<Description>A table containing mail properties</Description>
				<Type>table</Type>
				<Default />
				<Required>1</Required>
				<EasyMode>
					<Default>nil</Default>
					<DataType>table</DataType>
					<Constraints>none</Constraints>
				</EasyMode>
			</Arg>
      <Arg>
        <Name>ServerProperties</Name>
        <Description>A table containing server properties</Description>
        <Type>table</Type>
        <Default />
        <Required>1</Required>
        <EasyMode>
          <Default>nil</Default>
          <DataType>table</DataType>
          <Constraints>none</Constraints>
        </EasyMode>
      </Arg>
      <Arg>
        <Name>Attachments</Name>
        <Description>A numerically indexed table containing (FULL) paths of attachments of the mail , Set nil if no attachments.</Description>
        <Type>table</Type>
        <Default />
        <Required>1</Required>
        <EasyMode>
          <Default>nil</Default>
          <DataType>table</DataType>
          <Constraints>none</Constraints>
        </EasyMode>
      </Arg>
		</Arguments>
	</Action>
</ActionTemplates>