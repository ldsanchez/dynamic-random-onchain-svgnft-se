import React, { useEffect, useState } from "react";
import { Card, List, Spin } from "antd";
import { Address } from "../components";

function BoringAvatars({ readContracts, mainnetProvider, blockExplorer, totalSupply, DEBUG }) {
  const [allBoringAvatars, setAllBoringAvatar] = useState();
  const [page, setPage] = useState(1);
  const [loadingBoringAvatars, setLoadingBoringAvatars] = useState(true);
  const perPage = 8;

  useEffect(() => {
    const updateAllBoringAvatars = async () => {
      if (readContracts.DynamicRSVGNFT && totalSupply) {
        setLoadingBoringAvatars(true);
        const collectibleUpdate = [];
        let startIndex = totalSupply - 1 - perPage * (page - 1);
        for (let tokenIndex = startIndex; tokenIndex > startIndex - perPage && tokenIndex >= 0; tokenIndex--) {
          try {
            if (DEBUG) console.log("Getting token index", tokenIndex);
            const tokenId = await readContracts.DynamicRSVGNFT.tokenByIndex(tokenIndex);
            if (DEBUG) console.log("Getting BoringAvatar tokenId: ", tokenId);
            const tokenURI = await readContracts.DynamicRSVGNFT.tokenURI(tokenId);
            if (DEBUG) console.log("tokenURI: ", tokenURI);
            const jsonManifestString = atob(tokenURI.substring(29));

            try {
              const jsonManifest = JSON.parse(jsonManifestString);
              collectibleUpdate.push({ id: tokenId, uri: tokenURI, ...jsonManifest });
            } catch (e) {
              console.log(e);
            }
          } catch (e) {
            console.log(e);
          }
        }
        setAllBoringAvatar(collectibleUpdate);
        setLoadingBoringAvatars(false);
      }
    };
    updateAllBoringAvatars();
  }, [readContracts.DynamicRSVGNFT, (totalSupply || "0").toString(), page]);

  return (
    <div style={{ width: "auto", margin: "auto", paddingBottom: 25, minHeight: 800 }}>
      {false ? (
        <Spin style={{ marginTop: 100 }} />
      ) : (
        <div>
          <List
            grid={{
              gutter: 16,
              xs: 1,
              sm: 2,
              md: 2,
              lg: 3,
              xl: 4,
              xxl: 4,
            }}
            pagination={{
              total: totalSupply,
              defaultPageSize: perPage,
              defaultCurrent: page,
              onChange: currentPage => {
                setPage(currentPage);
              },
              showTotal: (total, range) => `${range[0]}-${range[1]} of ${totalSupply} items`,
            }}
            loading={loadingBoringAvatars}
            dataSource={allBoringAvatars}
            renderItem={item => {
              const id = item.id.toNumber();

              return (
                <List.Item key={id + "_" + item.uri + "_" + item.owner}>
                  <Card
                    title={
                      <div>
                        <span style={{ fontSize: 18, marginRight: 8 }}>{item.name}</span>
                      </div>
                    }
                  >
                    <img src={item.image} alt={"Boring Avatar #" + id} width="200" />
                    <div>{item.description}</div>
                    <div>
                      <Address
                        address={item.owner}
                        ensProvider={mainnetProvider}
                        blockExplorer={blockExplorer}
                        fontSize={16}
                      />
                    </div>
                  </Card>
                </List.Item>
              );
            }}
          />
        </div>
      )}
    </div>
  );
}

export default BoringAvatars;
