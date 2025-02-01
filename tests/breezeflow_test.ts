import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures weather data can be submitted by authorized oracle",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const oracle = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("breezeflow", "submit-weather", 
        ["New York", types.int(72), "Sunny"], oracle.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    
    // Add more assertions
  },
});

Clarinet.test({
  name: "Ensures activities can be added and retrieved",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("breezeflow", "add-activity",
        ["New York", "Sunny", "Central Park Picnic"], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    
    // Add more assertions
  },
});
