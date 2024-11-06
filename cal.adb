-- Adina Mubbashir
-- March 4, 2024
-- Program displays Gregorian Calendar to user in English and French

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Characters.Handling; use Ada.Characters.Handling;

procedure cal is
    type calArray is array(0..23, 0..20) of integer;
    userYear     : integer;
    firstDay     : integer;
    userLang     : string(1..1); 
    gregorianCal : calArray;
    
    -- Function to check if a year is valid 
    function isvalid(userYear  : in integer) return boolean is
    begin
        return userYear  >= 1582;
    end isvalid;

    -- Procedure to get input from the user
    procedure readcalinfo(userYear  : out integer; firstDay : out integer; userLang : out string) is
        langInput     : character;
        previousYear  : integer;
    begin
        loop
            put_line("Enter the year: ");
            get(userYear );
            if isvalid(userYear ) then
                exit;
            else
                put_line("Invalid year. Please enter a year after 1581.");
            end if;
        end loop;

        -- Calculate the first day of the year
        previousYear := userYear  - 1;
        firstDay := (36 + previousYear + (previousYear / 4) - (previousYear / 100) + (previousYear / 400)) mod 7;

        -- Getting preferred language
        loop
            put_line("Enter E for calendar in English and F for French : ");
            get(langInput);
            langInput := to_upper(langInput);
            if langInput = 'E' or else langInput = 'F' then
                userLang := (1 => langInput);
                exit;
            else
                put_line("Invalid input. Please enter E or F.");
            end if;
        end loop;
    end readcalinfo;

    -- Function to determine if the year user provded is a leap year
    function leapyear(userYear  : in integer) return boolean is
    begin
        return (userYear  mod 4 = 0 and then userYear  mod 100 /= 0) or else (userYear  mod 400 = 0);
    end leapyear;

    -- Function to determine days in a month
    function numdaysinmonth(monthDays : in integer; userYear  : in integer) return integer is
    begin
        case monthDays is
            -- These months always have 31 days.
            when 1 | 3 | 5 | 7 | 8 | 10 | 12 => return 31; 
            -- These months always have 30 days.
            when 4 | 6 | 9 | 11             => return 30;
            -- Check for leap yar to determine if it has 28 or 29 days. 
            when 2                          => 
                if leapyear(userYear ) then
                    return 29;
                else
                    return 28;
                end if;
            when others => return 0; 
        end case;
    end numdaysinmonth;

    -- Function to build the calnder
    function buildcalendar(YearPicked: integer; dayFirst: integer) return calArray is
        gregorianCal: calArray := (others => (others => 0)); 
        currentDay: Integer := dayFirst; 
        dayOfMonth: Integer := 1; 
    begin
        for i in 1..12 loop
            declare
                daysInMonth: constant Integer := NumdaysInMonth(i, YearPicked);
                rowCal: Integer; 
                columnCal: Integer; 
            begin
                -- Calculate the starting row and column for the current month
                rowCal := ((i - 1) / 3) * 6;
                columnCal := ((i - 1) mod 3) * 7;
                dayOfMonth := 1; -- Reset for each month

                -- Fill the calendar for the current month
                while dayOfMonth <= daysInMonth loop
                    for week in 0..5 loop 
                        for weekDay in 0..6 loop 
                            if dayOfMonth > daysInMonth then
                                exit; -- Stop if we've filled all days of the month
                            elsif week = 0 and weekDay < currentDay then
                                null; -- Skip days until we reach the first day of the month
                            else
                                -- Fill the day ito the calendar
                                gregorianCal(rowCal + week, columnCal + weekDay) := dayOfMonth;
                                dayOfMonth := dayOfMonth + 1;
                            end if;
                        end loop;
                        exit when dayOfMonth > daysInMonth; 
                    end loop;

                    -- Next month
                    currentDay := (currentDay + daysInMonth) mod 7;
                end loop;
            end;
        end loop;

        return gregorianCal;
    end buildcalendar;

    -- Procedure to print the month name, year, and week heading
    procedure printrowheading(rowHeading: integer; userLang : string) is
        monthNumber : integer;
    begin
        -- Calculate the start for the months in the row
        monthNumber := rowHeading* 3 + 1; 

        -- Print the month names for the row
        for i in 0 .. 2 loop
            put(" ");
            for j in 1 .. 3 loop
                put("  ");
            end loop;

            -- Print the month names in both English and French
            if userLang = "E" then
                case monthNumber + I is
                    when 1  => put("January  ");
                    when 2  => put("     February ");
                    when 3  => put("     March   ");
                    when 4  => put("April   ");
                    when 5  => put("      May    ");
                    when 6  => put("       June   ");
                    when 7  => put("July   ");
                    when 8  => put("       August  ");
                    when 9  => put("      September ");
                    when 10 => put("October  ");
                    when 11 => put("     November  ");
                    when 12 => put("    December");
                    when others => null;
                end case;
            elsif userLang = "F" then
                            case monthNumber + I is
                    when 1 => put("Janvier  ");
                    when 2 => put("     Février ");
                    when 3 => put("      Mars ");
                    when 4 => put("Avril     ");
                    when 5 => put("    Mai ");
                    when 6 => put("          Juin ");
                    when 7 => put("Juillet ");
                    when 8 => put("      Août ");
                    when 9 => put("         Septembre ");
                    when 10 => put("Octobre ");
                    when 11 => put("      Novembre ");
                    when 12 => put("     Décembre");
                    when others => null;
                end case;
            end if;

            -- Print spaces for padding after month name
            for i in 1 .. 3 loop
                put(" ");
            end loop;
        end loop;
        new_line;

        -- Print day names for the week according to the seleted language
        if userLang = "E" then
            put_line("Su Mo Tu We Th Fr Sa    Su Mo Tu We Th Fr Sa    Su Mo Tu We Th Fr Sa");
        elsif userLang = "F" then
            put_line("Di Lu Ma Me Je Ve Sa    Di Lu Ma Me Je Ve Sa    Di Lu Ma Me Je Ve Sa");
        end if;
    end printrowheading;

    -- Procedure to print the dates of the months in a row in a calendar
    procedure printrowmonth(gregorianCal : calArray; spaceRow: integer) is
        rowBegin : integer;
    begin
        rowBegin := spaceRow* 6; 

        for i in rowBegin..rowBegin + 5 loop
            for col in 0..20 loop
                -- Format spacing between months 
                if col = 7 or else col = 14 then
                    put("   ");
                end if;

                -- Making sure to check if the day should be displayed or left blank.
                if gregorianCal(i, col) = 0 then
                    put("  "); 
                else
                    -- Condition for single-digit 
                    if gregorianCal(i, col) < 10 then
                        put(" "); 
                    end if;
                     -- Display the day.
                    put(Item => gregorianCal(i, col), Width => 1);
                end if;
                put(" "); 
            end loop;
            new_line; 
        end loop;
    end printrowmonth;

    --Procedure to print the calendar banner
    procedure banner(targetYear: integer; spaceIndent: integer) is
       type fontArray is array(0..9, 1..10) of string(1..13);
       yearDigits : array(1..4) of Integer;
       fileData : file_Type;
       digitsRepresentation : fontArray; 
       lineFile : string(1..13);
       digitsCount : integer; 
    begin
       -- Open file with data
       Open(fileData, In_File, "font.txt");

       -- Fill in the digits from the font file
       for digitIndex in 0..9 loop
          for lineIndex in 1..10 loop
             lineFile := get_Line(fileData);
             digitsRepresentation(digitIndex, lineIndex) := lineFile(1..lineFile'Length);
          end loop;
       end loop;

       -- Clse file
       Close(fileData);

       -- Year into digits
       digitsCount := 0;
       declare
          temp : Integer := targetYear;
       begin
          while temp > 0 loop
             digitsCount := digitsCount + 1;
             yearDigits(digitsCount) := temp mod 10;
             temp := temp / 10;
          end loop;
       end;

       -- Output the year banner with indent
       for line in 1..10 loop
          for indentStep in 1..spaceIndent loop
             put(" ");
          end loop;

          -- Output each digit of the year
          for digitPosition in reverse 1..digitsCount loop
             put(digitsRepresentation(yearDigits(digitPosition), line));
          end loop;

          new_line;
       end loop;
    end banner;

begin
    readcalinfo(userYear , firstDay, userLang);
     new_line;
      banner(userYear , 6);
      new_line;

    gregorianCal := buildcalendar(userYear, firstDay);

    for row in 0..3 loop
      printRowHeading(row, userLang);
      printrowmonth(gregorianCal, row);
      new_line;
   end loop;

end cal;
