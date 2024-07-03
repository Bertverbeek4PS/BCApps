// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.AITestToolkit;
// TODO: Do we need this for v1?
page 149038 "AIT Log Entry API"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'aiTestToolkit';
    APIVersion = 'v1.0';
    Caption = 'AI Test Logs Entries';
    EntityCaption = 'AI Test Logs Entry';
    EntitySetCaption = 'AI Test Log Entries';
    EntityName = 'aiTestLogEntry';
    EntitySetName = 'aitTestLogEntries';
    SourceTable = "AIT Log Entry";
    ODataKeyFields = SystemId;
    Extensible = false;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("aitCode"; Rec."Test Suite Code")
                {
                    Caption = 'AIT Code';
                    Editable = false;
                    NotBlank = true;
                    TableRelation = "AIT Test Suite";
                }
                field("lineNumber"; Rec."Test Method Line No.")
                {
                    Caption = 'Line No.';
                }
                field("tag"; Rec.Tag)
                {
                    Caption = 'Tag';
                }
                field("version"; Rec.Version)
                {
                    Caption = 'Version No.';
                }
                field("entryNumber"; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field("startTime"; Rec."Start Time")
                {
                    Caption = 'Start Time';
                }
                field("endTime"; Rec."End Time")
                {
                    Caption = 'End Time';
                }
                field("codeunitID"; Rec."Codeunit ID")
                {
                    Caption = 'Codeunit ID';
                }
                field("codeunitName"; Rec."Codeunit Name")
                {
                    Caption = 'Codeunit Name';
                }
                field("procedureName"; Rec."Procedure Name")
                {
                    Caption = 'Function Name';
                }
                field("operation"; Rec.Operation)
                {
                    Visible = false;
                    Enabled = false;
                    Caption = 'Operation';
                }
                field("message"; MessageTxt)
                {
                    Caption = 'Message';
                }
                field("durationMin"; Rec."Duration (ms)")
                {
                    Caption = 'Duration (ms)';
                }
                field("status"; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(dataset; Rec."Test Input Group Code")
                {
                    Caption = 'Dataset';
                }
                field("datasetLineNumber"; Rec."Test Input Code")
                {
                    Caption = 'Dataset Line No.';
                }
                field("inputData"; this.InputText)
                {
                    Caption = 'Input Data';
                }
                field("outputData"; this.OutputText)
                {
                    Caption = 'Output Data';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                { 
                    Caption = 'Last Modified Date Time';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        this.InputText := Rec.GetInputBlob();
        this.OutputText := Rec.GetOutputBlob();
        this.MessageTxt := Rec.GetMessage();
    end;

    var
        InputText: Text;
        OutputText: Text;
        MessageTxt: Text;
}