using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Com.Reactlibrary.RNCaffe2
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNCaffe2Module : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNCaffe2Module"/>.
        /// </summary>
        internal RNCaffe2Module()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNCaffe2";
            }
        }
    }
}
