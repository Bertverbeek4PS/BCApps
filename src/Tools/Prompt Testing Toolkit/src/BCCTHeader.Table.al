// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;
using System.TestTools.TestRunner;


table 149030 "BCCT Header"
{
    DataClassification = SystemMetadata;
    Extensible = false;
    ReplicateData = false;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Description"; Text[250])
        {
            Caption = 'Description';
        }
        field(4; Status; Enum "BCCT Header Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(5; "Started at"; DateTime)
        {
            Caption = 'Started at';
            Editable = false;
        }
        field(6; "Default Delay (ms)"; Integer)
        {
            Caption = 'Default Delay (ms) between tests';
            InitValue = 100;
            MinValue = 1;
            MaxValue = 10000;
        }
        field(7; Dataset; Text[100])
        {
            Caption = 'Dataset';
            TableRelation = "BCCT Dataset"."Dataset Name";
        }
        field(8; "Ended at"; DateTime)
        {
            Caption = 'Ended at';
            Editable = false;
        }
        field(9; "Duration"; Duration)
        {
            Caption = 'Duration';
            Editable = false;
        }
        field(10; "No. of tests running"; Integer)
        {
            Caption = 'No. of tests running';
            trigger OnValidate()
            var
                BCCTLine: Record "BCCT Line";
                BCCTHeaderCU: Codeunit "BCCT Header";
            begin
                if "No. of tests running" < 0 then
                    "No. of tests running" := 0;

                if "No. of tests running" <> 0 then
                    exit;

                case Status of
                    Status::Running:
                        begin
                            BCCTLine.SetRange("BCCT Code", "Code");
                            BCCTLine.SetRange(Status, BCCTLine.Status::" ");
                            if not BCCTLine.IsEmpty then
                                exit;
                            BCCTHeaderCU.SetRunStatus(Rec, Rec.Status::Completed);
                            BCCTLine.SetRange("BCCT Code", "Code");
                            BCCTLine.SetRange(Status);
                            BCCTLine.ModifyAll(Status, BCCTLine.Status::Completed);
                        end;
                    Status::Cancelled:
                        begin
                            BCCTLine.SetRange("BCCT Code", "Code");
                            BCCTLine.ModifyAll(Status, BCCTLine.Status::Cancelled);
                        end;
                end;
            end;
        }
        field(11; Tag; Text[20])
        {
            Caption = 'Tag';
            DataClassification = CustomerContent;
        }
#pragma warning disable AA0232
        // TODO: Remove pragma and add to SIFT
        field(12; "Total Duration (ms)"; Integer)
#pragma warning restore AA0232
        {
            Caption = 'Total Duration (ms)';
            // ToolTip ='Specifies the Total Duration (ms) for executing all the tests in the current version.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("BCCT Log Entry"."Duration (ms)" where("BCCT Code" = field("Code"), Version = field("Version"), Operation = const('Execute Procedure'), "Procedure Name" = filter(<> '')));
        }
        field(13; Version; Integer)
        {
            Caption = 'Version';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(14; "Default Min. User Delay (ms)"; Integer)
        {
            Caption = 'Default Min. User Delay (ms)';
            InitValue = 100;
            MinValue = 100;
            MaxValue = 10000;
        }
        field(15; "Default Max. User Delay (ms)"; Integer)
        {
            Caption = 'Default Max. User Delay (ms)';
            InitValue = 1000;
            MinValue = 100;
            MaxValue = 30000;

            trigger OnValidate()
            begin
                if "Default Max. User Delay (ms)" < "Default Min. User Delay (ms)" then
                    "Default Max. User Delay (ms)" := "Default Min. User Delay (ms)";
            end;
        }
        field(16; "Base Version"; Integer)
        {
            Caption = 'Base Version';
            DataClassification = CustomerContent;
            MinValue = 0;
            trigger OnValidate()
            begin
                if "Base Version" > Version then
                    Error(BaseVersionMustBeLessThanVersionErr)
            end;
        }
        field(19; RunID; Guid)
        {
            Caption = 'Unique RunID';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(20; ModelVersion; Option) //TODO: Change this enum
        {
            Caption = 'AOAI Model Version';
            OptionMembers = Latest,Preview;
            DataClassification = SystemMetadata;
        }
        field(21; "No. of Tests Executed"; Integer)
        {
            Caption = 'No. of Tests Executed';
            // ToolTip ='Specifies the number of tests executed in the current version.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("BCCT Log Entry" where("BCCT Code" = field("Code"), "Version" = field("Version"), Operation = const('Execute Procedure'), "Procedure Name" = filter(<> '')));
        }
        field(22; "No. of Tests Passed"; Integer)
        {
            Caption = 'No. of Tests Passed';
            // ToolTip ='Specifies the number of tests passed in the current version.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("BCCT Log Entry" where("BCCT Code" = field("Code"), "Version" = field("Version"), Operation = const('Execute Procedure'), "Procedure Name" = filter(<> ''), Status = const(0)));
        }
        field(23; "No. of Operations"; Integer) //TODO: Change the name to No. of Scenarios? 
        {
            Caption = 'No. of Operations';
            // ToolTip ='Specifies the number of operations executed including "Execute Procedure" operation for the current version.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("BCCT Log Entry" where("BCCT Code" = field("Code"), "Version" = field("Version")));
        }
        field(31; "No. of Tests Executed - Base"; Integer)
        {
            Caption = 'No. of Tests Executed';
            // ToolTip ='Specifies the number of tests executed in the base version.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("BCCT Log Entry" where("BCCT Code" = field("Code"), "Version" = field("Base Version"), Operation = const('Execute Procedure'), "Procedure Name" = filter(<> '')));
        }
        field(32; "No. of Tests Passed - Base"; Integer)
        {
            Caption = 'No. of Tests Passed';
            // ToolTip ='Specifies the number of tests passed in the base version.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("BCCT Log Entry" where("BCCT Code" = field("Code"), "Version" = field("Base Version"), Operation = const('Execute Procedure'), "Procedure Name" = filter(<> ''), Status = const(0)));
        }
        field(33; "No. of Operations - Base"; Integer) //TODO: Change the name to No. of Scenarios? 
        {
            Caption = 'No. of Operations';
            // ToolTip ='Specifies the number of operations executed including "Execute Procedure" operation for the base version.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("BCCT Log Entry" where("BCCT Code" = field("Code"), "Version" = field("Base Version")));
        }
        field(34; "Total Duration (ms) - Base"; Integer)
        {
            Caption = 'Total Duration (ms) - Base';
            // ToolTip ='Specifies the Total Duration (ms) for executing all the tests in the base version.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("BCCT Log Entry"."Duration (ms)" where("BCCT Code" = field("Code"), Version = field("Base Version"), Operation = const('Execute Procedure'), "Procedure Name" = filter(<> '')));
        }
        field(50; "Test Runner Id"; Integer)
        {
            Caption = 'Test Runner Id';
            Editable = false;

            trigger OnValidate()
            var
                ALTestSuite: Record "AL Test Suite";
            begin
                if ALTestSuite.Get(Rec.Code) then begin
                    ALTestSuite."Test Runner Id" := Rec."Test Runner Id";
                    ALTestSuite.Modify(true);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Dataset; Dataset)
        {
        }
    }

    var
        BaseVersionMustBeLessThanVersionErr: Label 'Base Version must be less than or equal to Version';
}