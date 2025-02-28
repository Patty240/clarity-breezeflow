import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures oracle management works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const oracle = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("breezeflow", "add-oracle", 
        [types.principal(oracle.address)], deployer.address)
    ]);
    
    assertEquals(block.receipts[0].result, '(ok true)');
    
    block = chain.mineBlock([
      Tx.contractCall("breezeflow", "remove-oracle", 
        [types.principal(oracle.address)], deployer.address)
    ]);
    
    assertEquals(block.receipts[0].result, '(ok true)');
  },
});

Clarinet.test({
  name: "Ensures weather data validation works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const oracle = accounts.get("wallet_1")!;
    
    // Add oracle first
    chain.mineBlock([
      Tx.contractCall("breezeflow", "add-oracle", 
        [types.principal(oracle.address)], deployer.address)
    ]);
    
    let block = chain.mineBlock([
      Tx.contractCall("breezeflow", "submit-weather", 
        ["New York", types.int(200), "Sunny"], oracle.address)
    ]);
    
    assertEquals(block.receipts[0].result, `(err u104)`);
  },
});

Clarinet.test({
  name: "Ensures activity rating system works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("breezeflow", "add-activity",
        ["New York", "Sunny", "Central Park Picnic"], deployer.address),
      Tx.contractCall("breezeflow", "rate-activity",
        ["New York", "Sunny", types.uint(5)], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    assertEquals(block.receipts[1].result, '(ok true)');
  },
});
