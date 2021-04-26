1. Remove Unused Factories on Main Branch
2. When test suit passing merge
3. Rebase alma_requests against this branch
4. Update factories with new IDs
5. Update other "vcr" recordings with new IDs on alma_requests
6. Convert Voyager hold request to Alma Hold Requests
7. Align statuses for "negative statuses" with Alma conventions
8. Make sure new "remote_storage" locations are treated as ReCAP locations
9. Remove uneeded SCSB availability call (should only happen for PUL recap and SCSB Items from Partners)
10. 