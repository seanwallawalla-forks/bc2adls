// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License. See LICENSE in the project root for license information.
table 82560 "ADLSE Setup"
{
    Access = Internal;
    DataClassification = CustomerContent;
    DataPerCompany = false;
    DataCaptionFields = Container;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            Editable = false;
        }
        field(2; Container; Text[63])
        {
            Caption = 'Container';

            trigger OnValidate()
            var
                ADLSEExecution: Codeunit "ADLSE Execution";
            begin
                // Name constraints based on https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-containers--blobs--and-metadata
                if (StrLen(Container) < 3) or (StrLen(Container) > 63) // between 6 and 63 characters long
                    or TextContainerCharactersOtherThan(Container, 'abcdefghijklmnopqrstuvwxyz1234567890-') // only made of lower case letters, numerals and dashes
                    or (StrPos(Container, '--') <> 0) // no occurence of multiple dashes together
                then
                    Error(ContainerNameIncorrectFormatErr);
            end;
        }

        field(3; MaxPayloadSizeMiB; Integer)
        {
            Caption = 'Max payload size (MiBs)';
            InitValue = 4;
            // Refer max limit for pub block calls (https://docs.microsoft.com/en-us/rest/api/storageservices/put-block#remarks)
            MaxValue = 4000;
            MinValue = 1;
        }

        field(10; Running; Boolean)
        {
            Caption = 'Exporting data';
            Editable = false;
        }

        field(11; "Emit telemetry"; Boolean)
        {
            Caption = 'Emit telemetry';
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        ContainerNameIncorrectFormatErr: Label 'The container name is in an incorrect format.';

    local procedure TextContainerCharactersOtherThan(String: Text; CharString: Text): Boolean
    var
        Index: Integer;
        Letter: Text;
    begin
        for Index := 1 to StrLen(String) do begin
            Letter := CopyStr(String, Index, 1);
            if StrPos(CharString, Letter) = 0 then
                exit(true);
        end;
    end;

}