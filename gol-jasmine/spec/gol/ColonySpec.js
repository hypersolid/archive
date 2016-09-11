var _ = require('underscore');

var Colony = require('../../lib/Colony');
var Cell = require('../../lib/Cell');

describe("Colony", function() {

  it("return first cell", function() {
    cell = new Cell();
    colony = new Colony([cell]);
    expect(colony.cells).toEqual([cell]);
  });

  it("return cells hash", function() {
    cell1 = new Cell(0, 0);
    cell2 = new Cell(101, 102);
    colony = new Colony([cell1, cell2]);

    expect(colony.cellsHash).toEqual({
      '0_0': cell1,
      '101_102': cell2
    });
  });

  it("clears dead cell", function() {
    cell = new Cell(0, 0);
    cell.dead = true;
    colony = new Colony([cell]);
    expect(colony.cells.length).toEqual(1);

    colony.clearDeadCells();
    expect(Object.keys(colony.cellsHash).length).toEqual(0);
  });

  // OO  becomes OO
  // OO          OO
  it("lives or dies v1", function() {
    colony = new Colony([new Cell(0, 0), new Cell(0, 1), new Cell(1, 0), new Cell(1, 1)]);
    colony.liveOrDie();

    expect(_.map(colony.cells, function(obj) {
      return obj.dead
    })).toEqual([false, false, false, false]);
  });


  // OOOO becomes XOOX
  it("lives or dies v2", function() {
    colony = new Colony([new Cell(0, 0), new Cell(0, 1), new Cell(0, 2), new Cell(0, 3)]);
    colony.liveOrDie();

    expect(_.map(colony.cells, function(obj) {
      return obj.dead
    })).toEqual([true, false, false, true]);
  });

  // OOO           OXO
  // OOO  becomes  XXX
  // OOO           OXO
  it("lives or dies v3", function() {
    colony = new Colony([
      new Cell(-1, 1), new Cell(0, 1), new Cell(1, 1),
      new Cell(-1, 0), new Cell(0, 0), new Cell(1, 0),
      new Cell(-1, -1), new Cell(0, -1), new Cell(1, -1),
    ]);
    colony.liveOrDie();

    expect(_.map(colony.cells, function(obj) {
      return obj.dead
    })).toEqual([
      false, true, false,
      true, true, true,
      false, true, false
    ]);
  });


  // OX           OO
  // OO  becomes  OO
  it("thrives v1", function() {
    colony = new Colony([
      new Cell(-1, -1), new Cell(-1, 0), new Cell(0, -1)
    ]);

    colony.thrive();

    expect(_.map(colony.cellsHash, function(obj) {
      return obj.dead
    })).toEqual([
      false, false,
      false, false
    ]);
  });

});
