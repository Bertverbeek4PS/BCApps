// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

page 149034 "BCCT Lines"
{
    Caption = 'Tests';
    PageType = ListPart;
    SourceTable = "BCCT Line";
    AutoSplitKey = true;
    DelayedInsert = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("LoadTestCode"; Rec."BCCT Code")
                {
                    ToolTip = 'Specifies the ID of the BCCT.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field(LineNo; Rec."Line No.")
                {
                    ToolTip = 'Specifies the line number of the BCCT line.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field(CodeunitID; Rec."Codeunit ID")
                {
                    ToolTip = 'Specifies the codeunit id to run.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(CodeunitName; Rec."Codeunit Name")
                {
                    ToolTip = 'Specifies the name of the codeunit.';
                    ApplicationArea = All;
                }
                field(Dataset; Rec.Dataset)
                {
                    ToolTip = 'Specifies a dataset that overrides the default dataset for the suite.';
                    ApplicationArea = All;
                }
                field("Delay (ms btwn. iter.)"; Rec."Delay (ms btwn. iter.)")
                {
                    ToolTip = 'Specifies the delay between iterations.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the BCCT line.';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the BCCT.';
                    ApplicationArea = All;
                }
                field(MinDelay; Rec."Min. User Delay (ms)")
                {
                    ToolTip = 'Specifies the min. user delay in ms of the BCCT.';
                    ApplicationArea = All;
                }
                field(MaxDelay; Rec."Max. User Delay (ms)")
                {
                    ToolTip = 'Specifies the max. user delay in ms of the BCCT.';
                    ApplicationArea = All;
                }
                field("No. of Tests"; Rec."No. of Tests")
                {
                    Tooltip = 'Specifies the number of tests in this Line';
                    ApplicationArea = All;
                }
                field("No. of Tests Passed"; Rec."No. of Tests Passed")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the number of tests passed in the current Version.';
                }
                field("No. of Tests Failed"; Rec."No. of Tests" - Rec."No. of Tests Passed")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'No. of Tests Failed';
                    ToolTip = 'Specifies the number of tests that failed in the current Version.';
                    Style = Unfavorable;

                    trigger OnDrillDown()
                    var
                        BCCTHeaderRec: Record "BCCT Header";
                    begin
                        BCCTHeaderRec.SetLoadFields(Version); // TODO: See if  there is a better way to do this
                        BCCTHeaderRec.Get(Rec."BCCT Code");
                        FailedTestsBCCTLogEntryDrillDown(BCCTHeaderRec.Version);
                    end;
                }
                field("No. of Operations"; Rec."No. of Operations")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of operations in the current Version.';
                }
                field(Duration; Rec."Total Duration (ms)")
                {
                    ToolTip = 'Specifies Total Duration of the BCCT for this role.';
                    ApplicationArea = All;
                }
                field(AvgDuration; BCCTLineCU.GetAvgDuration(Rec))
                {
                    ToolTip = 'Specifies average duration of the BCCT for this role.';
                    Caption = 'Average Duration (ms)';
                    ApplicationArea = All;
                }
                field("No. of Tests - Base"; Rec."No. of Tests - Base")
                {
                    Tooltip = 'Specifies the number of tests in this Line for the base version.';
                    ApplicationArea = All;
                }
                field("No. of Tests Passed - Base"; Rec."No. of Tests Passed - Base")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of tests passed in the base Version.';
                    Style = Favorable;
                }
                field("No. of Tests Failed - Base"; Rec."No. of Tests - Base" - Rec."No. of Tests Passed - Base")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'No. of Tests Failed - Base';
                    ToolTip = 'Specifies the number of tests that failed in the base Version.';
                    Style = Unfavorable;

                    trigger OnDrillDown()
                    var
                        BCCTHeaderRec: Record "BCCT Header";
                    begin
                        BCCTHeaderRec.SetLoadFields("Base Version"); // TODO: See if  there is a better way to do this
                        BCCTHeaderRec.Get(Rec."BCCT Code");
                        FailedTestsBCCTLogEntryDrillDown(BCCTHeaderRec."Base Version");
                    end;
                }
                field("Input Dataset"; Rec."Input Dataset")
                {
                    ToolTip = 'Specifies the input dataset for the BCCT line.';
                    ApplicationArea = All;
                }
                field("No. of Operations - Base"; Rec."No. of Operations - Base")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of operations in the base Version.';
                }
                field(DurationBase; Rec."Total Duration - Base (ms)")
                {
                    ToolTip = 'Specifies Total Duration of the BCCT for this role for the base version.';
                    Caption = 'Total Duration Base (ms)';
                    ApplicationArea = All;
                }
                field(AvgDurationBase; GetAvg(Rec."No. of Tests - Base", Rec."Total Duration - Base (ms)"))
                {
                    ToolTip = 'Specifies average duration of the BCCT for this role for the base version.';
                    Caption = 'Average Duration Base (ms)';
                    ApplicationArea = All;
                }
                field(AvgDurationDeltaPct; GetDiffPct(GetAvg(Rec."No. of Tests - Base", Rec."Total Duration - Base (ms)"), GetAvg(Rec."No. of Tests", Rec."Total Duration (ms)")))
                {
                    ToolTip = 'Specifies difference in duration of the BCCT for this role compared to the base version.';
                    Caption = 'Change in Duration (%)';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            //             action(New)
            //             {
            //                 ApplicationArea = All;
            //                 Caption = 'New';
            //                 Image = New;
            //                 Scope = Repeater;
            //                 ToolTip = 'Add a new line.';

            //                 trigger OnAction()
            //                 var
            //                     NextBCCTLine: Record "BCCT Line";
            //                 begin
            //                     // Missing implementation for very first record
            //                     NextBCCTLine := Rec;
            //                     Rec.init();
            // #pragma warning disable AA0181
            //                     if NextBCCTLine.Next() <> 0 then
            // #pragma warning restore AA0181
            //                         Rec."Line No." := (NextBCCTLine."Line No." - Rec."Line No.") div 2
            //                     else
            //                         Rec."Line No." += 10000;
            //                     Rec.Insert(true);
            //                 end;
            //             }
            action(Start)
            {
                ApplicationArea = All;
                Caption = 'Run';
                Image = Start;
                Tooltip = 'Starts running the BCCT Line.';

                trigger OnAction()
                begin
                    BCCTHeader.Get(Rec."BCCT Code");
                    BCCTHeader.Version += 1;
                    BCCTHeader.Modify();
                    Commit();
                    // If no range is set, all following foreground lines will be run
                    Rec.SetRange("Codeunit ID", Rec."Codeunit ID");
                    Codeunit.Run(codeunit::"BCCT Role Wrapper", Rec);
                    Rec.SetRange("Codeunit ID"); // reset filter
                end;
            }
            action(Indent)
            {
                ApplicationArea = All;
                Visible = false;
                Caption = 'Make Child';  //'Indent';
                Image = Indent;
                ToolTip = 'Make this process a child of the above session.';
                trigger OnAction()
                begin
                    BCCTLineCU.Indent(Rec);
                end;
            }
            action(Outdent)
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
                Caption = 'Make Session';  //'Outdent';
                Image = DecreaseIndent;
                ToolTip = 'Make this process its own session.';

                trigger OnAction()
                begin
                    BCCTLineCU.Outdent(Rec);
                end;
            }
            action(LogEntries)
            {
                ApplicationArea = All;
                Caption = 'Log Entries';
                Image = Entries;
                ToolTip = 'Open log entries for the line.';
                RunObject = page "BCCT Log Entries";
                RunPageLink = "BCCT Code" = field("BCCT Code"), "BCCT Line No." = field("Line No."), Version = field("Version Filter");
            }
        }
    }
    var
        BCCTHeader: Record "BCCT Header";
        BCCTLineCU: Codeunit "BCCT Line";

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Min. User Delay (ms)" := BCCTHeader."Default Min. User Delay (ms)";
        Rec."Max. User Delay (ms)" := BCCTHeader."Default Max. User Delay (ms)";
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec."BCCT Code" = '' then
            exit(true);
        if Rec."BCCT Code" <> BCCTHeader.Code then
            if BCCTHeader.Get(Rec."BCCT Code") then;
    end;

    local procedure GetAvg(NumIterations: Integer; TotalNo: Integer): Integer
    begin
        if NumIterations = 0 then
            exit(0);
        exit(TotalNo div NumIterations);
    end;

    local procedure GetDiffPct(BaseNo: Integer; No: Integer): Decimal
    begin
        if BaseNo = 0 then
            exit(0);
        exit(round((100 * (No - BaseNo)) / BaseNo, 0.1));
    end;

    internal procedure Refresh()
    begin
        CurrPage.Update(false);
        if Rec.Find() then;
    end;

    local procedure FailedTestsBCCTLogEntryDrillDown(VersionNo: Integer)
    var
        BCCTLogEntries: Record "BCCT Log Entry";
        BCCTLogEntry: Page "BCCT Log Entries";
    begin
        BCCTLogEntries.SetFilterForFailedTestProcedures();
        BCCTLogEntries.SetRange("BCCT Code", Rec."BCCT Code");
        BCCTLogEntries.SetRange(Version, VersionNo);
        BCCTLogEntries.SetRange("BCCT Line No.", Rec."Line No.");
        BCCTLogEntry.SetTableView(BCCTLogEntries);
        BCCTLogEntry.Run();
    end;
}