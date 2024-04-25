// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

using System.TestTools.TestRunner;

codeunit 149042 "BCCT Role Wrapper"
{
    TableNo = "BCCT Line";
    SingleInstance = true;
    Access = Internal;

    var
        GlobalBCCTLine: Record "BCCT Line";
        GlobalBCCTHeader: Record "BCCT Header";
        ActiveBCCTHeader: Record "BCCT Header";
        GlobalBCCTDatasetLine: Record "BCCT Dataset Line";
        NoOfInsertedLogEntries: Integer;
        AccumulatedWaitTimeMs: Integer;

    trigger OnRun();
    //var
    // PoissonLimit: Integer;
    //StartTime: DateTime;
    //CurrentWorkDate: Date;
    begin
        if Rec."Codeunit ID" = 0 then
            exit;
        SetBCCTLine(Rec);

        NoOfInsertedLogEntries := 0;
        AccumulatedWaitTimeMs := 0;
        //PoissonLimit := 0;
        InitializeBCCTLineForRun(Rec, ActiveBCCTHeader);
        SetBCCTHeader(ActiveBCCTHeader);

        ExecuteBCCTLine(Rec, ActiveBCCTHeader);
    end;

    local procedure InitializeBCCTLineForRun(var BCCTLine: Record "BCCT Line"; var BCCTHeader: Record "BCCT Header")
    begin
        BCCTHeader.Get(BCCTLine."BCCT Code");
        if BCCTHeader."Started at" < CurrentDateTime() then
            BCCTHeader."Started at" := CurrentDateTime();
        // if BCCTHeader."Work date starts at" = 0D then
        //     BCCTHeader."Work date starts at" := Today;
        if BCCTLine.Dataset = '' then
            BCCTLine.Dataset := (BCCTHeader.Dataset);

        if BCCTLine."Delay (ms btwn. iter.)" < 1 then
            BCCTLine."Delay (ms btwn. iter.)" := BCCTHeader." Default Delay (ms)";

        // if BCCTLine."Delay Type" = BCCTLine."Delay Type"::Random then
        //     if BCCTLine."Delay (sec. btwn. iter.)" = 0 then
        //         PoissonLimit := 0
        //     else // This was based on heuristics and does not behave as a true Poisson process, but only a rough approximation.
        //         PoissonLimit := 1000000 - 1000000 div BCCTLine."Delay (sec. btwn. iter.)";
    end;

    local procedure ExecuteBCCTLine(var BCCTLine: Record "BCCT Line"; var BCCTHeader: Record "BCCT Header")
    var
        BCCTDatasetLine: Record "BCCT Dataset Line";
        BCCTHeaderCU: Codeunit "BCCT Header";
        //BCCTRunType: Enum "BCCT Run Type";
        DoRun: Boolean;
        ExecuteNextIteration: Boolean;
    begin
        DoRun := true; //decide if we want different type of runs
        ExecuteNextIteration := true;
        Randomize();

        BCCTDatasetLine.Reset();
        BCCTDatasetLine.SetRange(BCCTDatasetLine."Dataset Name", BCCTLine.Dataset);
        if not BCCTDatasetLine.FindSet() then
            exit;

        repeat
            if DoRun then begin

                GetAndClearAccumulatedWaitTimeMs();
                GetAndClearNoOfLogEntriesInserted();

                // BCCTLineCU.StartScenario(ScenarioLbl);
                SetBCCTDatasetLine(BCCTDatasetLine);
                OnBeforeExecuteIteration(BCCTHeader, BCCTLine, BCCTDatasetLine);
                ExecuteIteration(BCCTLine, BCCTDatasetLine);
                Commit();
            end;

            BCCTHeader.Find();
            if BCCTHeader.Status = BCCTHeader.Status::Cancelled then
                ExecuteNextIteration := false;


            if ExecuteNextIteration then
                if BCCTLine."Run in Foreground" then begin // rotate between foreground scenarios in this thread
                    if BCCTLine.Next() = 0 then
                        if BCCTLine.FindSet() then ExecuteNextIteration := BCCTDatasetLine.Next() <> 0;
                    Sleep(BCCTLine."Delay (ms btwn. iter.)");
                end
                else
                    ExecuteNextIteration := BCCTDatasetLine.Next() <> 0;

        //TODO override delay from line / default delay


        until (ExecuteNextIteration = false);
        BCCTHeaderCU.DecreaseNoOfTestsRunningNow(BCCTHeader);
    end;

    local procedure ExecuteIteration(var BCCTLine: Record "BCCT Line"; BCCTDatasetLine: Record "BCCT Dataset Line")
    var
        TestMethodLine: Record "Test Method Line";
        TestRunnerIsolDisabled: Codeunit "Test Runner - Isol. Disabled";
    begin
        SetBCCTLine(BCCTLine);
        TestMethodLine."Line Type" := TestMethodLine."Line Type"::Codeunit;
        TestMethodLine."Skip Logging Results" := true;
        TestMethodLine."Test Codeunit" := BCCTLine."Codeunit ID";
        //TODO: Set input
        if BCCTDatasetLine.Input <> '' then;
        //TestMethodLine."Input Data" := BCCTDatasetLine.Input;
        // WasSuccess := true; // init in case the event subscriber is not called
        TestRunnerIsolDisabled.Run(TestMethodLine);  // WasSuccess is set in an eventsubscriber
    end;

    // internal procedure GetScenarioLbl(): Text[100]
    // begin
    //     exit(ScenarioLbl);
    // end;

    internal procedure GetBCCTHeaderTag(): Text[20]
    begin
        exit(ActiveBCCTHeader.Tag);
    end;

    /// <summary>
    /// Sets the BCCT Line so that the test codeunits can retrieve.
    /// </summary>
    local procedure SetBCCTLine(var BCCTLine: Record "BCCT Line")
    begin
        GlobalBCCTLine := BCCTLine;
    end;

    /// <summary>
    /// Gets the BCCT Line stored through the SetBCCTLine method.
    /// </summary>
    internal procedure GetBCCTLine(var BCCTLine: Record "BCCT Line")
    begin
        BCCTLine := GlobalBCCTLine;
    end;

    local procedure SetBCCTDatasetLine(var BCCTDatasetLine: Record "BCCT Dataset Line")
    begin
        GlobalBCCTDatasetLine := BCCTDatasetLine;
    end;

    internal procedure GetBCCTDatasetLine(var BCCTDatasetLine: Record "BCCT Dataset Line")
    begin
        BCCTDatasetLine := GlobalBCCTDatasetLine;
    end;

    local procedure SetBCCTHeader(var CurrBCCTHeader: Record "BCCT Header")
    begin
        GlobalBCCTHeader := CurrBCCTHeader;
    end;

    internal procedure GetBCCTHeader(var CurrBCCTHeader: Record "BCCT Header")
    begin
        CurrBCCTHeader := GlobalBCCTHeader;
    end;

    internal procedure AddToNoOfLogEntriesInserted()
    begin
        NoOfInsertedLogEntries += 1;
    end;

    internal procedure GetNoOfLogEntriesInserted(): Integer
    var
        ReturnValue: Integer;
    begin
        ReturnValue := NoOfInsertedLogEntries;
        exit(ReturnValue);
    end;

    internal procedure GetAndClearNoOfLogEntriesInserted(): Integer
    var
        ReturnValue: Integer;
    begin
        ReturnValue := NoOfInsertedLogEntries;
        NoOfInsertedLogEntries := 0;
        exit(ReturnValue);
    end;

    internal procedure AddToAccumulatedWaitTimeMs(ms: Integer)
    begin
        AccumulatedWaitTimeMs += ms;
    end;

    internal procedure GetAndClearAccumulatedWaitTimeMs(): Integer
    var
        ReturnValue: Integer;
    begin
        ReturnValue := AccumulatedWaitTimeMs;
        AccumulatedWaitTimeMs := 0;
        exit(ReturnValue);
    end;

    [InternalEvent(false)]
    procedure OnBeforeExecuteIteration(var BCCTHeader: Record "BCCT Header"; var BCCTLine: Record "BCCT Line"; var BCCTDatasetLine: Record "BCCT Dataset Line")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnAfterTestMethodRun', '', false, false)]
    local procedure OnAfterTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    var
        BCCTContextCU: Codeunit "BCCT Test Context";
    begin
        Commit();
        if FunctionName = '' then
            exit;
        BCCTContextCU.EndScenario(FunctionName, IsSuccess); //TODO is the context codeunit used correctly?
        Commit();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnBeforeTestMethodRun', '', false, false)]
    local procedure OnBeforeTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions)
    var
        BCCTContextCU: Codeunit "BCCT Test Context";
    begin
        if FunctionName = '' then
            exit;
        BCCTContextCU.StartScenario(FunctionName);
    end;
}