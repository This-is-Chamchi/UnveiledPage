using UnityEngine;
using System;

public abstract class DataContainer<T> : ScriptableObject where T : class
{
    [SerializeField] protected T[] dataArray;

    public T[] Datas 
    {
        get { return dataArray; }
    }

    public int Length
    {
        get
        {
            Debug.Assert(dataArray != null, $"{name} Data table이 초기화 되지 않았습니다.");
            return dataArray.Length;
        }
    }

    public T this[int index]
    {
        get
        {
            Debug.Assert(dataArray != null, $"{name} Data table is Not Initialized.");
            Debug.Assert(index >= 0 && index < dataArray.Length, $"{name} Index Out of Range,");
            return dataArray[index];
        }
    }

    public T this[uint index]
    {
        get
        {
            return this[(int)index];
        }
    }

    public void SetDataContainer(T[] input)
    {
        dataArray = input;
    }    
}