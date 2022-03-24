package utilities

import (
	"encoding/hex"
	"encoding/json"
	"hash"

	"golang.org/x/crypto/ripemd160"
)

const HashLabelName = "utilities.operators.sample.ibm.com/hash"

func GetHashForSpec(specStruct interface{}) string {
	byteArray, _ := json.Marshal(specStruct)
	var hasher hash.Hash
	hasher = ripemd160.New()
	hasher.Reset()
	hasher.Write(byteArray)
	return hex.EncodeToString(hasher.Sum(nil))
}

func SetHashToLabels(labels map[string]string, specHashActual string) map[string]string {
	if labels == nil {
		labels = map[string]string{}
	}
	labels[HashLabelName] = specHashActual
	return labels
}

func GetHashFromLabels(labels map[string]string) string {
	return labels[HashLabelName]
}
