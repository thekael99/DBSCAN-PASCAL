// program Hello;
// begin
//   writeln ('Hello, world.');
// end.
program db(epsilon, min_points, file_data); 
uses 
  math,
  SysUtils; 
type 
  Point = record
    x: real; 
    y: real;
    clusterID: integer ; 
  end; 
  points= array  of Point ;
  pointsInt = array of integer; 
const 
  UNCLASSIFIED = -1;
  CORE_POINT = 1;
  BORDER_POINT = 2 ;
  NOISE = -2  ; 
  SUCCESS =0 ; 
  FAILURE = -3; 
  //MIN_POINTS =3; 
var 
  totalPoints: points;
  clusterID: integer;  
  N:longint;  
  iter:longint;
  EPSILON:real;
  MIN_POINTS: integer;
  data: string;

// print all points

procedure readData(filename: string; var totalPoints: points);
var 
  i, num: longint;
  f: Text;
begin
  assign(f, filename);
  reset(f);
  readln(f, num);
  setLength(totalPoints, num);
  for i:=0 to num-1 do
  begin
    read(f,totalPoints[i].x);
    read(f,totalPoints[i].y);
    totalPoints[i].clusterID := UNCLASSIFIED;
  end;
  close(f);
end;

procedure writeResult(filename: string; totalPoints: points);
var 
  i, num: longint;
  f: Text;
begin
  assign(f, filename);
  rewrite(f);
  num := Length(totalPoints);
  writeln(f,'x',',','y',',','cluster');
  for i:=0 to num-1 do
    writeln(f, totalPoints[i].x, ',',totalPoints[i].y, ',', totalPoints[i].clusterID);
  close(f);
end;

procedure print(totalPoints: points);
var i:longint; 
begin
  for i:=0 to Length(totalPoints)-1 do 
    begin
      write(i, ' ', totalPoints[i].x, ' ', totalPoints[i].y, ' ', totalPoints[i].clusterID);
      writeln; 
    end; 
  writeln('----------------------------------------------');
end;

//print array of neighbor 
procedure printCluster(clusterSeeds: pointsInt);
var i:longint; 
begin
  for i:=0 to Length(clusterSeeds)-1 do 
    begin
      write(clusterSeeds[i], ' ', totalPoints[clusterSeeds[i]].x, ' ', totalPoints[clusterSeeds[i]].y, ' ', totalPoints[clusterSeeds[i]].clusterID);
      writeln; 
    end; 
  writeln('----------------------------------------------');
end;
function calculateDistance(pointCore: Point; pointTarget: Point): real; 
begin
  Exit(Power(pointCore.x-pointTarget.x, 2)+ Power(pointCore.y-pointTarget.y, 2))
end; 

function calculateCluster(point: Point): pointsInt; 
var 
  index: integer; 
  iter: longint; 
  clusterIndex: pointsInt; 
  numPointsAroundCenter: longint;
  distance:real; 
begin
  index:=0;
  numPointsAroundCenter:=0;
  for iter:=0 to N do 
    begin
      distance:=calculateDistance(point,totalPoints[iter]);
      if ((distance<=EPSILON) and (distance>=0) ) then 
        begin
          numPointsAroundCenter:=numPointsAroundCenter+1;
        end; 
    end; 
  //writeln(numPointsAroundCenter);
  setLength(clusterIndex, numPointsAroundCenter); 
  for iter:=0 to N do 
    begin
      distance:=calculateDistance(point,totalPoints[iter]);
      if ((distance<=EPSILON) and (distance>=0) ) then
        begin
          clusterIndex[index]:= iter; 
          index:=index+1; 
        end; 
      
    end; 
  Exit(clusterIndex); 
end;

function expandCluster(iter: longint; clusterID:integer; invokeFromCluster: boolean):integer; 
var 
  clusterSeeds : pointsInt; 
  iterSeeds : longint; 
  
begin  
  clusterSeeds:= calculateCluster(totalPoints[iter]);
  //printCluster(clusterSeeds);
  if ((Length(clusterSeeds) < MIN_POINTS) and (totalPoints[iter].clusterID=UNCLASSIFIED) and (invokeFromCluster=FALSE)) then 
    begin
      totalPoints[iter].clusterID:=NOISE; 
      EXIT(FAILURE); 
    end
  else
    begin
      //printCluster(clusterSeeds);
      totalPoints[iter].clusterID:=clusterID;
        
          // if ((totalPoints[clusterSeeds[iterSeeds]].x <> totalPoints[iter].x) or (totalPoints[clusterSeeds[iterSeeds]].y <> totalPoints[iter].y)) then 
      
      for iterSeeds:= 0 to Length(clusterSeeds)-1 do
        begin
          if (totalPoints[clusterSeeds[iterSeeds]].clusterID=UNCLASSIFIED) 
          then expandCluster(clusterSeeds[iterSeeds], clusterID, TRUE);
        end;
      EXIT(SUCCESS); 
    end; 
end; 



begin {Start Program }
  // setLength(totalPoints, 10);
  // totalPoints[0].x:=2; totalPoints[0].y:=2; totalPoints[0].clusterID:=UNCLASSIFIED;
  // totalPoints[1].x:=2.5; totalPoints[1].y:=2.5; totalPoints[1].clusterID:=UNCLASSIFIED;
  // totalPoints[2].x:=2; totalPoints[2].y:=1.5; totalPoints[2].clusterID:=UNCLASSIFIED;
  // totalPoints[3].x:=4; totalPoints[3].y:=0; totalPoints[3].clusterID:=UNCLASSIFIED;
  // totalPoints[4].x:=1; totalPoints[4].y:=2; totalPoints[4].clusterID:=UNCLASSIFIED;
  // totalPoints[5].x:=50; totalPoints[5].y:=2; totalPoints[5].clusterID:=UNCLASSIFIED;
  // totalPoints[6].x:=4; totalPoints[6].y:=2; totalPoints[6].clusterID:=UNCLASSIFIED;
  // totalPoints[7].x:=0; totalPoints[7].y:=0; totalPoints[7].clusterID:=UNCLASSIFIED;
  // totalPoints[8].x:=4; totalPoints[8].y:=3; totalPoints[8].clusterID:=UNCLASSIFIED;
  // totalPoints[9].x:=2.5; totalPoints[9].y:=3; totalPoints[9].clusterID:=UNCLASSIFIED;
  EPSILON := StrToFloat(paramStr(1));
  MIN_POINTS :=StrToInt(paramStr(2));
  data := paramStr(3); 
  readData(data, totalPoints);
  N:=Length(totalPoints);

  clusterID :=1 ;

  for iter:=0 to N-1 do 
    begin 
      if (totalPoints[iter].clusterID=UNCLASSIFIED) then 
        if (expandCluster(iter, clusterID, FALSE) = SUCCESS ) then 
          clusterID:=clusterID+1;
    end;

  expandCluster(0, clusterID, FALSE);
  print(totalPoints);
  writeResult('res.txt', totalPoints)
end.