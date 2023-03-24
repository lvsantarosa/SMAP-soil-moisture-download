//GEE code: https://code.earthengine.google.com/?scriptPath=users%2Flucassantarosa%2FSBSR%3ADatasets%2FNASA_USDA_HSL_SMAP10KM_soil_moisture

var batch = require('users/fitoprincipe/geetools:batch');

var dataset = ee.ImageCollection('NASA_USDA/HSL/SMAP10KM_soil_moisture')
                  .filter(ee.Filter.date('2022-01-01', '2022-01-31'));
                  


function clp(img) {
  return img.clip(geometry)
}

var soilMoisture = dataset.select('susm').map(clp);

print(soilMoisture)

var soilMoistureVis = {
  min: 0.0,
  max: 50.0,
  palette: ['0300ff', '418504', 'efff07', 'efff07', 'ff0303'],
};

var count = soilMoisture.size()

var all_tiles = soilMoisture.map(function(image) { return image.multiply(1).clip(geometry).reproject('EPSG:4326', null, 10000); }); 
  
var collectionList = all_tiles.toList(all_tiles.size());
var n = collectionList.size().getInfo();

for (var i = 0; i < n; i++) {
      var listOfImages = all_tiles.toList(all_tiles.size());
      var Tile = listOfImages.get(i);
      var allRasters = ee.ImageCollection.fromImages([Tile]);
      
      batch.Download.ImageCollection.toDrive(allRasters, 'SMAP10KM_soil_moisture', 
      {name: '{system:index}',
      scale: 10000,
      region: geometry
      })
}

Map.addLayer(all_tiles)

/**
 
 
Copy and paste below code into the console, then Enter; Below is the step-by-step:

Run your Google Earth Engine code;

Wait until all the tasks are listed (the Run buttons are shown);

Click f12 to bring up console;


function runTaskList(){
// var tasklist = document.getElementsByClassName('task local type-EXPORT_IMAGE awaiting-user-config');
// for (var i = 0; i < tasklist.length; i++)
//         tasklist[i].getElementsByClassName('run-button')[0].click();
$$('.run-button' ,$$('ee-task-pane')[0].shadowRoot).forEach(function(e) {
     e.click();
})
}


function confirmAll() {
// var ok = document.getElementsByClassName('goog-buttonset-default goog-buttonset-action');
// for (var i = 0; i < ok.length; i++)
//     ok[i].click();
$$('ee-table-config-dialog, ee-image-config-dialog').forEach(function(e) {
     var eeDialog = $$('ee-dialog', e.shadowRoot)[0]
     var paperDialog = $$('paper-dialog', eeDialog.shadowRoot)[0]
     $$('.ok-button', paperDialog)[0].click()
})
}

runTaskList();

confirmAll();


**/