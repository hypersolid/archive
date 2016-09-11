var _ = require('underscore');
var $ = require('jquery');

var Cell = require('./Cell');
var Colony = require('./Colony');

function Field() {
  this.colonies = [];
  this.size = 50;
}

Field.prototype.addColony = function(colony) {
  this.colonies.push(colony);
};

Field.prototype.removeEmptyColonies = function() {
  this.colonies = _.filter(this.colonies, function(colony) {
    return Object.keys(colony.cellsHash).length > 0;
  });
};

Field.prototype.compressColonies = function() {
  for (var i1 in this.colonies) {
    for (var i2 in this.colonies) {
      if (i2 > i1) {
        if (this.mergeColonies(this.colonies[i1], this.colonies[i2])) {
          _.extend(
            this.colonies[i2].cellsHash,
            this.colonies[i1].cellsHash
          );
          this.colonies[i1].cellsHash = {};
        }
      }
    }
  }

  this.removeEmptyColonies();
};

Field.prototype.mergeColonies = function(colony1, colony2) {
  for (var k1 in colony1.cellsHash) {
    for (var k2 in colony2.cellsHash) {
      var cell1 = colony1.cellsHash[k1];
      var cell2 = colony2.cellsHash[k2];
      if (cell1.equal(cell2) || cell1.adjustent(cell2)) {
        return true;
      }
    };
  };
};

Field.prototype.allColonies = function() {
  return this.colonies;
};

Field.prototype.step = function() {
  this.compressColonies();

  for (var i in this.colonies) {
    this.colonies[i].liveOrDie();
    this.colonies[i].thrive();
    this.colonies[i].clearDeadCells();
  };
};

Field.prototype.seedColonies = function() {
  field.addColony(new Colony([
    new Cell(0, 0), new Cell(1, 0),
    new Cell(1, 1), new Cell(0, 1)
  ]));
  field.addColony(new Colony([
    new Cell(10, 10), new Cell(11, 11)
  ]));
};


Field.prototype.getRandomPos = function(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

Field.prototype.rseedColonies = function() {
  var pos_x = this.getRandomPos(-this.size/5, this.size/5);
  var pos_y = this.getRandomPos(-this.size/5, this.size/5);
  field.addColony(new Colony([
    new Cell(pos_x, pos_y)
  ]));
};


Field.prototype.go = function() {
  this.seedColonies();
  for (var i = 0; i < 2; i++) {
    this.step();
  }
};

Field.prototype.rgo = function() {
  var delay = 500;
  var steps = 200;
  for (var i = 0; i < this.size * 10; i++) {
    this.rseedColonies();
  };
  this.draw();
  var $this = this;
  for (var i = 0; i < steps; i++) {
    setTimeout(function() {
      $this.step()
    }, delay * (i + 1));
    setTimeout(function() {
      $this.draw()
    }, delay * (i + 1));
  }
};

Field.prototype.init = function() {
  for (var i = -this.size; i < this.size; i++) {
    for (var j = -this.size * 2; j < this.size * 2; j++) {
      $('body').append('<div id="x' + i + 'y' + j + '"></div>');
    }
    $('body').append('<div class="cl"></div>');
  }
}

Field.prototype.draw = function() {
  $('div').removeClass('active');
  for (var k in this.colonies) {
    for (var l in this.colonies[k].cellsHash) {
      var cell = this.colonies[k].cellsHash[l];
      $('#x' + cell.x + 'y' + cell.y).addClass('active');
    }
  }
}

module.exports = Field;
