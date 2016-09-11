var _ = require('underscore');

var Colony = require('../../lib/Colony');
var Cell = require('../../lib/Cell');
var Field = require('../../lib/Field');

describe("Field", function() {
  it("adds colonies", function() {
    colony1 = new Colony();
    colony2 = new Colony();
    field = new Field();

    field.addColony(colony1);
    field.addColony(colony2);

    expect(field.allColonies()).toEqual([colony1, colony2]);
  });

  it("merges colonies", function() {
    colony1 = new Colony([new Cell(0, 0)]);
    colony2 = new Colony([new Cell(0, 1)]);

    field = new Field();

    expect(field.mergeColonies(colony1, colony2)).toEqual(true);
  });

  it("compresses colonies", function() {
    colony1 = new Colony([new Cell(0, 0), new Cell(0, 1), new Cell(0, 2)]);
    colony2 = new Colony([new Cell(1, 0), new Cell(2, 0)]);
    colony3 = new Colony([new Cell(10, 10)]);

    field = new Field();

    field.addColony(colony1);
    field.addColony(colony2);
    field.addColony(colony3);

    field.compressColonies();

    expect(_.map(field.colonies, function(obj) {
      return Object.keys(obj.cellsHash).length
    })).toEqual([5, 1]);
  });

  it("compresses colonies HARD CASE", function() {
    colony1 = new Colony([new Cell(0, 0), new Cell(0, 1), new Cell(0, 2)]);
    colony2 = new Colony([new Cell(1, 0), new Cell(2, 0)]);
    colony3 = new Colony([new Cell(1, 1)]);

    field = new Field();

    field.addColony(colony1);
    field.addColony(colony2);
    field.addColony(colony3);

    field.compressColonies();

    expect(_.map(field.colonies, function(obj) {
      return Object.keys(obj.cellsHash).length
    })).toEqual([6]);
  });

  it("compresses colonies VERY HARD CASE", function() {
    colony1 = new Colony([new Cell(0, 0), new Cell(0, 1)]);
    colony2 = new Colony([new Cell(2, 0), new Cell(3, 0)]);
    colony3 = new Colony([new Cell(10, 10)]);

    field = new Field();

    field.addColony(colony1);
    field.addColony(colony2);
    field.addColony(colony3);

    field.compressColonies();

    expect(_.map(field.colonies, function(obj) {
      return Object.keys(obj.cellsHash).length
    })).toEqual([4, 1]);
  });

  it("remove empty colonies", function() {
    field = new Field();

    field.addColony(new Colony([]));
    field.addColony(new Colony([new Cell(0, 0)]));

    field.removeEmptyColonies();

    expect(field.colonies.length).toEqual(1);
  });


  it("Seeds colonies", function() {
    field = new Field();

    field.seedColonies();

    expect(field.colonies.length).toEqual(2);
  });

  it("Go & Fun", function() {
    field = new Field();

    field.go();

    expect(_.map(field.colonies[0].cells, function(obj) {
      return [obj.x, obj.y]
    })).toEqual([
      [0, 0],
      [1, 0],
      [1, 1],
      [0, 1]
    ]);
  });

});
