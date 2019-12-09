const Agrinsure = artifacts.require("Agrinsure");

module.exports = async function() {
  const Agrinsure = await Agrinsure.deployed();
  await Agrinsure.resetResult();

  resultReceived = await Agrinsure.resultReceived();
  result = await Agrinsure.result();
  console.log(`Received result: ${resultReceived}`);
  console.log(`Initial result: ${result.toString()}`);

  console.log("Making a Chainlink request using a Honeycomb job...");
  requestId = await Agrinsure.makeRequest.call();
  await Agrinsure.makeRequest();
  console.log(`Request ID: ${requestId}`);

  console.log("Waiting for the request to be fulfilled...");
  while (true) {
    const responseEvents = await Agrinsure.getPastEvents(
      "ChainlinkFulfilled",
      { filter: { id: requestId } }
    );
    if (responseEvents.length !== 0) {
      console.log("Request fulfilled!");
      break;
    }
  }

  resultReceived = await Agrinsure.resultReceived();
  result = await Agrinsure.result();
  console.log(`Received result: ${resultReceived}`);
  console.log(`Final result: ${result.toString()}`);

  process.exit();
};
