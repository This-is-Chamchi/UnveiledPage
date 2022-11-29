using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SortingLayer : MonoBehaviour
{
    [SerializeField] private string sortingLayerName;
    [SerializeField] private int sortingOrder;

    void Start()
    {
        MeshRenderer mesh = GetComponent<MeshRenderer>();
        mesh.sortingLayerName = sortingLayerName;
        mesh.sortingOrder = sortingOrder;
    }
}
